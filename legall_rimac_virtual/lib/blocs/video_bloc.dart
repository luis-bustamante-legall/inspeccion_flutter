import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class VideoBloc
    extends Bloc<VideoEvent, VideoState> {
  final VideosRepository _videosRepository;
  List<String> _uploadingVideos = [];
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
      yield VideoLoaded.withError(e.toString(), stackTrace: stackTrace);
    }
  }

  Stream<VideoState> _updateVideo(UpdateVideo event) async* {
    var appDir = await getApplicationDocumentsDirectory();
    for(var video in event.videos) {
      var cacheFile = File('${appDir.path}/${video.id}.mp4');
      if (await cacheFile.exists()) {
        video.localCache = cacheFile.path;
      }
    }
    yield VideoLoaded.successfully(event.videos);
  }

  Stream<VideoState> _uploadVideo(UploadVideo event) async* {
    _uploadingVideos.add(event.videoModel.id);
    try {
      yield VideoUploading(_uploadingVideos);
      await _videosRepository.uploadVideo(event.videoModel, event.data);
      _uploadingVideos.remove(event.videoModel.id);
    } catch(e) {
      _uploadingVideos.remove(event.videoModel.id);
      add(LoadVideo(event.videoModel.inspectionId));
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
  List<Object> get props => [VideoModel,data];
}

class AddVideo extends VideoEvent {
  final VideoModel videoModel;

  const AddVideo(this.videoModel);

  @override
  List<Object> get props => [videoModel];
}

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object> get props => [];
}

class VideoUninitialized extends VideoState {}

class VideoLoading extends VideoState {}

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

  factory VideoLoaded.withError(final String errorMessage,
      {final StackTrace stackTrace}) {
    assert(errorMessage != null);
    return VideoLoaded(false, null, errorMessage, stackTrace);
  }

  @override
  List<Object> get props => [videos];
}

class VideoUploading extends VideoState {
  final List<String> uploadingVideos;

  const VideoUploading(this.uploadingVideos);

  @override
  List<Object> get props => [uploadingVideos];
}