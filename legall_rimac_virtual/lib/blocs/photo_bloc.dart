import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class PhotoBloc
    extends Bloc<PhotoEvent, PhotoState> {
  final PhotosRepository _photosRepository;
  final List<String> _uploadingPhotos = [];
  StreamSubscription _photosSubscription;

  PhotoBloc({@required PhotosRepository repository})
      : assert(repository != null),
        _photosRepository = repository;

  @override
  PhotoState get initialState => PhotoUninitialized();

  @override
  Stream<PhotoState> mapEventToState(
      PhotoEvent event) async* {
    if (event is LoadPhoto) {
      yield* _loadPhoto(event);
    } else if (event is UpdatePhoto) {
      yield* _updatePhoto(event);
    } else if (event is UploadPhoto) {
      yield* _uploadPhoto(event);
    } else if (event is AddPhoto) {
      yield* _addPhoto(event);
    }
  }

  Stream<PhotoState> _loadPhoto(LoadPhoto event) async* {
    await _photosSubscription?.cancel();
    try {
      _photosSubscription = _photosRepository
          .get(event.inspectionId,event.photoType)
          .listen((event) {
        add(UpdatePhoto(event.toList()));
      });
    } catch (e, stackTrace) {
      yield PhotoLoaded.withError(e.toString(), stackTrace: stackTrace);
    }
  }

  Stream<PhotoState> _updatePhoto(UpdatePhoto event) async* {
    yield PhotoLoaded.successfully(event.photos);
  }

  Stream<PhotoState> _uploadPhoto(UploadPhoto event) async* {
    _uploadingPhotos.add(event.photoModel.id);
    try {
      yield PhotoUploading(_uploadingPhotos);
      await _photosRepository.uploadPhoto(event.photoModel, event.data);
      _uploadingPhotos.remove(event.photoModel.id);
    } catch(e,stackTrace) {
      print(e.toString());
      _uploadingPhotos.remove(event.photoModel.id);
      add(LoadPhoto(event.photoModel.inspectionId, event.photoModel.type));
    }
  }

  Stream<PhotoState> _addPhoto(AddPhoto event) async* {
    await _photosRepository.addPhoto(event.photoModel);
  }

  @override
  Future<void> close() {
    _photosSubscription?.cancel();
    return super.close();
  }
}

abstract class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object> get props => [];
}

class LoadPhoto extends PhotoEvent {
  final String inspectionId;
  final PhotoType photoType;

  const LoadPhoto(this.inspectionId,this.photoType);

  @override
  List<Object> get props => [inspectionId,photoType];
}

class UpdatePhoto extends PhotoEvent {
  final List<PhotoModel> photos;

  const UpdatePhoto(this.photos);

  @override
  List<Object> get props => [photos];
}

class UploadPhoto extends PhotoEvent {
  final PhotoModel photoModel;
  final Uint8List data;

  const UploadPhoto(this.photoModel,this.data);

  @override
  List<Object> get props => [photoModel,data];
}

class AddPhoto extends PhotoEvent {
  final PhotoModel photoModel;

  const AddPhoto(this.photoModel);

  @override
  List<Object> get props => [photoModel];
}

abstract class PhotoState extends Equatable {
  const PhotoState();

  @override
  List<Object> get props => [];
}

class PhotoUninitialized extends PhotoState {}

class PhotoLoading extends PhotoState {}

class PhotoLoaded extends PhotoState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final List<PhotoModel> photos;

  PhotoLoaded(this.success, this.photos, this.errorMessage, this.stackTrace);

  factory PhotoLoaded.successfully(
      List<PhotoModel> photos) {
    assert(photos != null);
    return PhotoLoaded(true, photos, null, null);
  }

  factory PhotoLoaded.withError(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return PhotoLoaded(false, null, errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [photos];
}

class PhotoUploading extends PhotoState {
  final List<String> uploadingPhotos;

  const PhotoUploading(this.uploadingPhotos);

  @override
  List<Object> get props => [uploadingPhotos];
}