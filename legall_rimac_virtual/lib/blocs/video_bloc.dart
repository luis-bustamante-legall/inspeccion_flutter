import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../repositories/repositories.dart';

class VideoBloc
    extends Bloc<VideoEvent, VideoState> {
  final VideosRepository _videosRepository;
  final List<String> _uploadingVideos = [];

  StreamSubscription _videosSubscription;

  VideoBloc({@required VideosRepository repository})
      : assert(repository != null),
        _videosRepository = repository;

  @override
  VideoState get initialState => VideoUninitialized();

  @override
  Stream<VideoState> mapEventToState(
      VideoEvent event) async* {
    if (event is LoadVideo) {
      yield* _loadVideo(event);
    } else if (event is UpdateVideo) {
      yield* _updateVideo(event);
    } else if (event is UploadVideo) {
      yield* _uploadVideo(event);
    } else if (event is CompleteUploadVideo) {
      yield event.state;
      add(UpdateVideo(event.videos));
    }
  }

  Stream<VideoState> _loadVideo(LoadVideo event) async* {
    await _videosSubscription?.cancel();
    try {
      _videosSubscription = _videosRepository
          .get(event.inspectionId)
          .listen((event) {
        add(UpdateVideo(event.toList()));
      });
    } catch (e, stackTrace) {
      yield VideoLoaded.fail(e.toString(), stackTrace: stackTrace);
    }
  }

  Stream<VideoState> _updateVideo(UpdateVideo event) async* {
    var appDir = await getApplicationDocumentsDirectory();
    for(var video in event.videos) {
      var cacheFile = File('${appDir.path}/${video.id}.mp4');
      if (await cacheFile.exists()) {
        video.localCache = cacheFile.path;
      } else if (video.resourceUrl != null){
        http.get(video.resourceUrl).then((response) => {
          if (response.statusCode == HttpStatus.ok) {
            cacheFile.writeAsBytesSync(response.bodyBytes,flush: true)
          }
        });
      }
    }
    if (_uploadingVideos.isEmpty) {
      if (state is VideoLoaded)
        yield VideoRefresh();
      yield VideoLoaded.successfully(event.videos);
    }
    else {
      if (state is VideoUploading)
        yield VideoRefresh();
      yield VideoUploading(event.videos,_uploadingVideos);
    }
  }

  Stream<VideoState> _uploadVideo(UploadVideo event) async* {
    var videos = <VideoModel>[];
    try {
      var currentState = state;
      _uploadingVideos.add(event.videoModel.id);
      if (currentState is VideoLoaded)
        videos = currentState.videos;
      else if (currentState is VideoUploading)
        videos = currentState.videos;
      yield VideoInitUpload();
      yield VideoUploading(videos,_uploadingVideos);
      _videosRepository.uploadVideo(event.videoModel, event.data)
      .then((value) {
        _uploadingVideos.remove(event.videoModel.id);
        add(CompleteUploadVideo(
            VideoUploadCompleted.successfully(event.videoModel.id),videos));
      }).catchError((e){
        _uploadingVideos.remove(event.videoModel.id);
        add(CompleteUploadVideo(
            VideoUploadCompleted.fail(e.toString(), null),videos));
      });
    } catch(e, stackTrace) {
      yield VideoUploadCompleted.fail(e.toString(), stackTrace);
      _uploadingVideos.remove(event.videoModel.id);
      add(UpdateVideo(videos));
    }
  }
  
  @override
  Future<void> close() {
    _videosSubscription?.cancel();
    return super.close();
  }
}

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class LoadVideo extends VideoEvent {
  final String inspectionId;
  
  const LoadVideo(this.inspectionId);

  @override
  List<Object> get props => [inspectionId];
}

class UpdateVideo extends VideoEvent {
  final List<VideoModel> videos;

  const UpdateVideo(this.videos);

  @override
  List<Object> get props => [videos];
}

class UploadVideo extends VideoEvent {
  final VideoModel videoModel;
  final Uint8List data;

  const UploadVideo(this.videoModel,this.data);

  @override
  List<Object> get props => [videoModel,data];
}

class AddVideo extends VideoEvent {
  final VideoModel photoModel;

  const AddVideo(this.photoModel);

  @override
  List<Object> get props => [photoModel];
}

class CompleteUploadVideo extends VideoEvent {
  final VideoUploadCompleted state;
  final List<VideoModel> videos;

  CompleteUploadVideo(this.state,this.videos);
}

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object> get props => [];
}

class VideoUninitialized extends VideoState {}

class VideoLoading extends VideoState {}
class VideoInitUpload extends VideoState {}
class VideoRefresh extends VideoState {}
class VideoUploadCompleted extends VideoState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final String videoId;

  VideoUploadCompleted(this.success,this.errorMessage,this.stackTrace,this.videoId);

  factory VideoUploadCompleted.successfully(String videoId)
  => VideoUploadCompleted(true, null,null, videoId);

  factory VideoUploadCompleted.fail(String error, StackTrace stackTrace)
  => VideoUploadCompleted(false,error,stackTrace, null);
}

class VideoUploading extends VideoState {
  final List<String> uploading;
  final List<VideoModel> videos;

  VideoUploading(
      this.videos,
      this.uploading);
  
  @override
  List<Object> get props => [uploading, videos];
}

class VideoLoaded extends VideoState {
  final bool success;
  final String errorMessage;
  final StackTrace stackTrace;
  final List<VideoModel> videos;

  VideoLoaded(this.success, this.videos, this.errorMessage, this.stackTrace);

  factory VideoLoaded.successfully(
      List<VideoModel> videos) {
    assert(videos != null);
    return VideoLoaded(true, videos, null, null);
  }

  factory VideoLoaded.fail(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return VideoLoaded(false, null, errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [success,errorMessage,stackTrace, videos];
}

