import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class PhotoBloc
    extends Bloc<PhotoEvent, PhotoState> {
  final PhotosRepository _photosRepository;

  StreamSubscription _photosSubscription;

  PhotoBloc({@required PhotosRepository repository})
      : assert(repository != null),
        _photosRepository = repository;

  @override
  PhotoState get initialState => PhotoUninitialized();

  @override
  Stream<PhotoState> mapEventToState(
      PhotoEvent event) async* {
    if (event is LoadPhotos) {
      yield* _loadPhotos(event);
    } else if (event is UpdatePhotos) {
      yield* _updatePhotos(event);
    } else if (event is UploadPhoto) {
      yield* _uploadPhoto(event);
    } else if (event is AddPhoto) {
      yield* _addPhoto(event);
    } else if (event is CompleteUploadPhoto) {
      yield event.state;
      await Future.delayed(Duration.zero);
      add(UpdatePhotos(event.state.photos??[]));
    }
  }

  Stream<PhotoState> _loadPhotos(LoadPhotos event) async* {
    yield PhotoLoading();
    await _photosSubscription?.cancel();
    try {
      _photosSubscription = _photosRepository
          .get(event.inspectionId,event.photoType)
          .listen((event) {
        add(UpdatePhotos(event.toList()));
      });
    } catch (e, stackTrace) {
      yield PhotoLoaded.fail(e.toString(), stackTrace: stackTrace);
    }
  }

  Stream<PhotoState> _updatePhotos(UpdatePhotos event) async* {
    var currentPhotos = (state.photos??[]);
    var newPhotos = event.photos;
    for (var photo in newPhotos) {
      var currentPhoto = currentPhotos
          .firstWhere((e) => e.id == photo.id,orElse: ()=> null);
      if (currentPhoto != null
          && currentPhoto.status == ResourceStatus.uploading
          && photo.status != ResourceStatus.uploaded)
        {
          photo.status = ResourceStatus.uploading;
        }
    }
    yield PhotoLoaded.successfully(newPhotos);
  }

  Stream<PhotoState> _uploadPhoto(UploadPhoto event) async* {
    try {
      var photo = (state.photos??[])
          .firstWhere((e) => e.id == event.photoModel.id,orElse: () => null);
      var photoStatus = photo?.status;
      _photosRepository.uploadPhoto(event.photoModel, event.data)
      .then((value) {
        add(CompleteUploadPhoto(
            PhotoUploadCompleted.successfully(state)));
      }).catchError((e,stackTrace){
        photo.status = photoStatus;
        add(CompleteUploadPhoto(
            PhotoUploadCompleted.fail(state,e.toString(), stackTrace)));
        FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason: 'UploadPhoto');
      });
      if (photo != null)
        photo.status = ResourceStatus.uploading;
      yield PhotoRefresh(state);
    } catch(e, stackTrace) {
      yield PhotoUploadCompleted.fail(state,e.toString(), stackTrace);
      add(UpdatePhotos(state.photos??[]));
      FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'UploadPhoto');
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

class LoadPhotos extends PhotoEvent {
  final String inspectionId;
  final PhotoType photoType;

  const LoadPhotos(this.inspectionId,this.photoType);

  @override
  List<Object> get props => [inspectionId,photoType];
}

class UpdatePhotos extends PhotoEvent {
  final List<PhotoModel> photos;
  const UpdatePhotos(this.photos);

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

class CompleteUploadPhoto extends PhotoEvent {
  final PhotoUploadCompleted state;
  CompleteUploadPhoto(this.state);
}

abstract class PhotoState extends Equatable {
  final List<PhotoModel> photos;
  PhotoState({this.photos});

  @override
  List<Object> get props => [];
}

class PhotoUninitialized extends PhotoState {}
class PhotoLoading extends PhotoState {}
class PhotoRefresh extends PhotoState {
    PhotoRefresh(PhotoState prevState):
        super(photos: prevState.photos??[]);
}

class PhotoUploadCompleted extends PhotoState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;

  PhotoUploadCompleted(this.success,this.errorMessage,this.stackTrace,List<PhotoModel> photos):
    super(photos: photos);

  factory PhotoUploadCompleted.successfully(PhotoState prevState)
    => PhotoUploadCompleted(true, null,null, prevState.photos??[]);

  factory PhotoUploadCompleted.fail(PhotoState prevState,String error, StackTrace stackTrace)
    => PhotoUploadCompleted(false,error,stackTrace,prevState.photos??[]);
}

class PhotoLoaded extends PhotoState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final List<PhotoModel> photos;

  PhotoLoaded(this.success, this.photos,this.errorMessage, this.stackTrace);

  factory PhotoLoaded.successfully(
      List<PhotoModel> photos) {
    assert(photos != null);
    return PhotoLoaded(true, photos, null, null);
  }

  factory PhotoLoaded.fail(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return PhotoLoaded(false, null,errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [photos];
}

