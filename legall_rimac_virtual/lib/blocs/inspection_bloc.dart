import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:legall_rimac_virtual/repositories/rest_repository.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class InspectionBloc
    extends Bloc<InspectionEvent, InspectionState> {
  final InspectionsRepository _inspectionsRepository;
  final SettingsRepository _settingsRepository;
  final RestRepository _restRepository=RestRepository();
  StreamSubscription _inspectionsSubscription;

  InspectionBloc({
    @required InspectionsRepository repository,
    @required SettingsRepository settings})
      : assert(repository != null && settings != null),
        _inspectionsRepository = repository,
        _settingsRepository = settings {
    var inspectionId = _settingsRepository.getInspectionId();
    if (inspectionId != null)
      add(LoadInspection(inspectionId));
  }

  @override
  InspectionState get initialState => InspectionUninitialized();

  void updateInspection() {
    var inspectionId = _settingsRepository.getInspectionId();
    if (inspectionId != null)
      add(LoadInspection(inspectionId));
  }

  @override
  Stream<InspectionState> mapEventToState(
      InspectionEvent event) async* {
    if (event is LoadInspection) {
      yield* _loadInspection(event);
    } else if (event is UpdateInspection) {
      yield* _updateInspection(event);
    } else if (event is UpdateInspectionData) {
      yield* _updateInspectionData(event);
    }
  }

  Stream<InspectionState> _loadInspection(LoadInspection event) async* {
    await _inspectionsSubscription?.cancel();
    try {
      _inspectionsSubscription = _inspectionsRepository
          .get(event.inspectionId)
          .listen((inspection) {
            add(UpdateInspection(inspection));
        });
    } catch (e, stackTrace) {
      yield InspectionLoaded.withError(e.toString(), stackTrace: stackTrace);
      FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'LoadInspection');
    }
  }

  Stream<InspectionState> _updateInspection(UpdateInspection event) async* {
    if (event.inspectionModel != null) {
      yield InspectionLoaded.successfully(event.inspectionModel);
    } else {
      yield InspectionLoaded.withError('Inspection not found');
    }
  }

  Stream<InspectionState> _updateInspectionData(UpdateInspectionData event) async* {
    try {
      switch(event.type) {
        case UpdateInspectionType.data:
          await _inspectionsRepository.updateData(event.inspectionModel);
          break;
        case UpdateInspectionType.status:
          await _inspectionsRepository.updateStatus(event.inspectionModel);
          break;
        case UpdateInspectionType.schedule:
          //await _inspectionsRepository.updateSchedule(event.inspectionModel);
          await _inspectionsRepository.updateNotification(event.inspectionModel);
          await _restRepository.updateScheduleRest(event.inspectionModel);
          break;
      }
      yield InspectionUpdated.successfully(event.type, event.inspectionModel);
      yield InspectionLoaded.successfully(event.inspectionModel);
    } catch(ex,stackTrace) {
      yield InspectionUpdated.withError(ex.toString(),stackTrace: stackTrace);
      yield InspectionLoaded.successfully(event.inspectionModel);
      FirebaseCrashlytics.instance.recordError(ex, stackTrace,
          reason: 'UpdateInspectionData');
    }
  }

  @override
  Future<void> close() {
    _inspectionsSubscription?.cancel();
    return super.close();
  }
}

abstract class InspectionEvent extends Equatable {
  const InspectionEvent();

  @override
  List<Object> get props => [];
}

class LoadInspection extends InspectionEvent {
  final String inspectionId;

  const LoadInspection(
      this.inspectionId);
}

class UpdateInspection extends InspectionEvent {
  final InspectionModel inspectionModel;

  const UpdateInspection(this.inspectionModel);

  @override
  List<Object> get props => [inspectionModel];
}

class UpdateInspectionData extends InspectionEvent {
  final InspectionModel inspectionModel;
  final UpdateInspectionType type;

  const UpdateInspectionData(this.inspectionModel,this.type);

  @override
  List<Object> get props => [inspectionModel,type];
}

enum UpdateInspectionType {
  data,
  status,
  schedule
}

abstract class InspectionState extends Equatable {
  const InspectionState();

  @override
  List<Object> get props => [];
}

class InspectionUninitialized extends InspectionState {}

class InspectionLoading extends InspectionState {}

class InspectionUpdated extends InspectionState {
  final bool success;
  final UpdateInspectionType type;
  final String errorMessage;
  final StackTrace stackTrace;
  final InspectionModel inspectionModel;

  const InspectionUpdated(this.success,this.type, this.inspectionModel, this.errorMessage, this.stackTrace);

  factory InspectionUpdated.successfully(
      UpdateInspectionType type,
      InspectionModel inspectionModel) {
    assert(inspectionModel != null);
    return InspectionUpdated(true,type, inspectionModel, null, null);
  }

  factory InspectionUpdated.withError(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return InspectionUpdated(false,null, null, errorMessage, stackTrace);
  }

}

class InspectionLoaded extends InspectionState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final InspectionModel inspectionModel;

  const InspectionLoaded(this.success, this.inspectionModel, this.errorMessage, this.stackTrace);

  factory InspectionLoaded.successfully(
      InspectionModel inspectionModel) {
    assert(inspectionModel != null);
    return InspectionLoaded(true, inspectionModel, null, null);
  }

  factory InspectionLoaded.withError(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return InspectionLoaded(false, null, errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [inspectionModel];
}