import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:legall_rimac_virtual/configuration.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';

class DeepLinkBloc
    extends Bloc<DeepLinkEvent, DeepLinkState> {
  final platform = MethodChannel('https.legall_rimac_virtual/channel');
  final events = EventChannel('https.legall_rimac_virtual/events');
  final SettingsRepository settingsRepository;
  final InspectionsRepository inspectionsRepository;
  StreamSubscription _streamSubscription;

  _validateLink(String link) {
    try {
      var uri = Uri.parse(link);
      print(uri.path);
      print(uri.scheme);
      print(uri.queryParameters);
      if (!uri.isScheme(Configuration.scheme))
        return false;
      if (uri.path != Configuration.path)
        return false;
      if (!uri.queryParametersAll.containsKey(Configuration.keyId))
        return false;
      return true;
    } catch (_) {
      print(_.toString());
      return false;
    }
  }

  _getToken(String link) {
    var uri = Uri.parse(link);
    return uri.queryParameters[Configuration.keyId];
  }

  DeepLinkBloc({this.settingsRepository,this.inspectionsRepository});

  @override
  DeepLinkState get initialState => DeepLinkEmpty();

  @override
  Stream<DeepLinkState> mapEventToState(
      DeepLinkEvent event) async* {
    if (event is CaptureDeepLink) {
      yield DeepLinkWaiting();
      yield* _captureDeepLink(event);
    } else if (event is CapturedDeepLink) {
      yield DeepLinkWaiting();
      if (event.link != null && _validateLink(event.link)) {
        var model = await inspectionsRepository.fromId(
            _getToken(event.link));
        print("'${_getToken(event.link)}'");
        if (model != null) {
          settingsRepository.setInspectionId(model.inspectionId);
          yield DeepLinkCaptured(model);
        }
        else
          yield DeepLinkInvalid();  
      }
      else
        yield DeepLinkInvalid();
    }
  }

  Stream<DeepLinkState> _captureDeepLink(CaptureDeepLink event) async*{
    var initialLink = await platform.invokeMethod('initialLink');
    if (initialLink != null) {
      add(CapturedDeepLink(initialLink));
    } else {
      var _settingId = settingsRepository.getInspectionId();
      if (_settingId != null) {
        var model = await inspectionsRepository.fromId(_settingId);
        if (model != null) {
          yield DeepLinkInitial(model);
        } else {
          yield DeepLinkEmpty();
        }
      }
      else
        yield DeepLinkEmpty();
    }
    _streamSubscription?.cancel();
    _streamSubscription = events.receiveBroadcastStream().listen((event) {
      add(CapturedDeepLink(event));
    });
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}

abstract class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();

  @override
  List<Object> get props => [];
}

class CaptureDeepLink extends DeepLinkEvent {
  const CaptureDeepLink();
}

class CapturedDeepLink extends DeepLinkEvent {
  final String link;

  const CapturedDeepLink(this.link);
}

abstract class DeepLinkState extends Equatable {
  const DeepLinkState();

  @override
  List<Object> get props => [];
}

class DeepLinkWaiting extends DeepLinkState {
  const DeepLinkWaiting();
}

class DeepLinkEmpty extends DeepLinkState {
  const DeepLinkEmpty();
}

class DeepLinkInitial extends DeepLinkState {
  final InspectionModel inspectionModel;

  DeepLinkInitial(this.inspectionModel);
}

class DeepLinkCaptured extends DeepLinkState {
  final InspectionModel inspectionModel;

  DeepLinkCaptured(this.inspectionModel);
}

class DeepLinkInvalid extends DeepLinkState {
  const DeepLinkInvalid();
}