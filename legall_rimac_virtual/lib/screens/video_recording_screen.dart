import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoRecordingResult {
  Uint8List preview;
  Uint8List videoData;

  VideoRecordingResult({
    this.preview,
    this.videoData
  });
}

class VideoRecordingScreen extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() => VideoRecordingScreenState();
}

class VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController _cameraController;
  VideoPlayerController _playerController;
  File videoFile;
  File previewFile;
  bool empty = true;
  bool recording = false;
  bool playing = false;
  int counter = 0;
  Timer timer;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      _cameraController = CameraController(cameras.first,ResolutionPreset.high);
      _cameraController.initialize().then((_) {
        setState(() {});
      });
    });
    getTemporaryDirectory().then((tempDir) {
      videoFile = File("${tempDir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4");
      previewFile = File("${tempDir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.png");
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (videoFile != null && videoFile.existsSync())
      videoFile.deleteSync();
    if (previewFile != null && previewFile.existsSync())
      previewFile.deleteSync();
  }

  Widget _cameraPreviewWidget() {
    return Container(
      color: Colors.black,
      child: Transform.scale(
        scale: 1 / _cameraController.value.aspectRatio,
        child:Center(
          child: AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          )
        )
      ),
    );
  }

  Widget _playerPreviewWidget() {
    return Container(
      color: Colors.black,
      child: Transform.scale(
          scale: 1 / _playerController.value.aspectRatio,
          child:Center(
              child: AspectRatio(
                aspectRatio: _playerController.value.aspectRatio,
                child: VideoPlayer(_playerController),
              )
          )
      ),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: CircularProgressIndicator(
      )
    );
  }

  Widget _body() {
    if (empty && _cameraController != null)
      return _cameraPreviewWidget();
    else if (!empty && _playerController != null)
      return _playerPreviewWidget();
    else
      return _loadingWidget();
  }

  void _stopRecording() async {
    try {
      await _cameraController.stopVideoRecording();
    } catch (ex) {
      _cameraController = CameraController(cameras.first,ResolutionPreset.high);
      await _cameraController.initialize();
      setState(() {});
      print(ex);
    }
    _playerController = VideoPlayerController.file(videoFile);
    await _playerController.initialize();
    _playerController.setLooping(true);
    setState(() {
      recording = false;
      empty = false;
    });
    timer.cancel();
  }

  void _startRecording() async {
    //Take preview image
    if (await previewFile.exists())
      previewFile.delete();
    await _cameraController.takePicture(previewFile.path);
    //Start to recording the video
    if (await videoFile.exists())
      videoFile.delete();
    _cameraController.startVideoRecording(videoFile.path);
    setState(() {
      recording = true;
      counter = 20;
    });
    timer = Timer.periodic(
        Duration(seconds: 1),
            (Timer t) async {
          counter--;
          setState(() {

          });
          if (counter == 0) {
            _stopRecording();
          }
        }
    );
  }

  void _startPlayVideo() async {
    setState(() {
      playing = true;
    });
    await _playerController.play();
  }

  void _stopPlayVideo() async {
    if (_playerController != null) {
      _playerController.seekTo(Duration(seconds: 0));
      _playerController.pause();
      setState(() {
        playing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Grabar vídeo'),
        actions: [
          Visibility(
            visible: !empty && !recording && !playing,
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                var data = await videoFile.readAsBytes();
                var preview = await previewFile.readAsBytes();
                await videoFile.delete();
                await previewFile.delete();
                videoFile = null;
                previewFile = null;
                Navigator.pop(context,VideoRecordingResult(
                  preview: preview,
                  videoData: data
                ));
              },
            ),
          ),
          Visibility(
            visible: !empty && !recording && !playing,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  empty = true;
                });
              },
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          _body(),
          Visibility(
            visible: recording,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 50,
                width: 50,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(60),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: 1 - (counter * 0.05),
                        backgroundColor: Colors.white.withAlpha(200),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text("$counter",
                          style: _t.textTheme.headline6.copyWith(
                             color: Colors.white
                          ),
                        ),
                      )
                    )
                  ],
                ),
              )
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(recording||playing ? Icons.stop: empty ? Icons.fiber_manual_record: Icons.play_arrow),
        backgroundColor: recording||playing ? Colors.red: Colors.indigo,
        onPressed: () {
          if (recording)
            _stopRecording();
          else if (playing)
            _stopPlayVideo();
          else if (empty)
            _startRecording();
          else
            _startPlayVideo();
        },
      ),
    );
  }
}