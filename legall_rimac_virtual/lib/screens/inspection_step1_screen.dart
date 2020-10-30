import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class InspectionStep1Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep1ScreenState();
}

class InspectionStep1ScreenState extends State<InspectionStep1Screen> {
  ThemeData _t;
  PickedFile _video;
  VideoPlayerController _playerController;
  ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    _t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inspección Virtual - Paso 1'),
        actions: [
          IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                //TODO: pass chat ID
                Navigator.pushNamed(context, AppRoutes.chat,
                  arguments: ''
                );
              }
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Cargar un video 360 del vehiculo, de un máximo de 20 segundos:'),
          SizedBox(height: 20,),
          ImageCard(
            child: (_playerController == null)?null:
            Transform.scale(
                scale: 1 / _playerController.value.aspectRatio,
                child:Center(
                    child: AspectRatio(
                      aspectRatio: _playerController.value.aspectRatio,
                      child: VideoPlayer(_playerController),
                    )
                )
            ),
            height: 120,
            title: Text('Video 360',
              style: _t.textTheme.button,
            ),
            icon: Icons.add,
            onTap: () async {
              var video = await _picker.getVideo(source: ImageSource.camera,
                maxDuration: Duration(seconds: 20)
              );
              if (video != null) {
                var videoFile = File(video.path);
                _video = video;
                setState(() {
                  _playerController = VideoPlayerController.file(videoFile);
                  _playerController.initialize();
                });
              }
            },
          ),
          SizedBox(height: 20,),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              color: _t.accentColor,
              child: Text('CONTINUAR',
                style: _t.accentTextTheme.button,
              ),
              onPressed: () async {
                Navigator.pushNamed(context, AppRoutes.inspectionStep2);
              },
            )
          )
        ],
      ),
    );
  }
}