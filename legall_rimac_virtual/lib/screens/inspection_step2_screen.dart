import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/photo_bloc.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/photo_model.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/resource_cache.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/chat_button.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legall_rimac_virtual/widgets/phone_call_button.dart';

class InspectionStep2Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep2ScreenState();
}

class InspectionStep2ScreenState extends State<InspectionStep2Screen> {
  final ImagePicker _picker = ImagePicker();
  SettingsRepository _settingsRepository;
  PhotoBloc _photoBloc;
  List<PhotoModel> _photos = [];
  List<String> _uploadingPhotos = [];
  ResourceCache _resourceCache = ResourceCache();

  @override
  void initState() {
    super.initState();
    _settingsRepository = RepositoryProvider.of<SettingsRepository>(context);
    _photoBloc = BlocProvider.of<PhotoBloc>(context);
    _photoBloc.add(LoadPhoto(
        _settingsRepository.getInspectionId(),
        PhotoType.predefined));
  }

  IconData _iconFromStatus(ResourceStatus status) {
    switch(status) {
      case ResourceStatus.empty:
        return Icons.add;
      case ResourceStatus.uploaded:
        return Icons.update;
      case ResourceStatus.approved:
        return Icons.check_circle;
      default:
        return Icons.cancel;
    }
  }

  Color _colorFromStatus(ResourceStatus status) {
    switch(status) {
      case ResourceStatus.empty:
        return Colors.indigo;
      case ResourceStatus.uploaded:
        return Colors.amber;
      case ResourceStatus.approved:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_l.translate('inspection step',arguments:{"step": "2" })),
        actions: [
          PhoneCallButton(),
          ChatButton()
        ],
      ),
      body: BlocBuilder<PhotoBloc,PhotoState>(
        builder: (context,state) {
          if (state is PhotoLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PhotoLoaded || state is PhotoUploading) {
            if (state is PhotoLoaded) {
              if (state.success) {
                _photos = state.photos;
              } else {
                print(state.errorMessage);
                Future.delayed(Duration(milliseconds: 100),() {
                  var messenger = Scaffold.of(context);
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.red,
                    content: ListTile(
                      leading: Icon(Icons.announcement_rounded),
                      title: Text(_l.translate('problems loading photos'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ));
                });
              }
            } else if (state is PhotoUploading) {
              _uploadingPhotos = state.uploadingPhotos;
            }
            return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Text(_l.translate('pick photos')),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.indigo
                            ),
                            child: Icon(Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(_l.translate('legend add'),
                              style: _t.textTheme.bodyText2,
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber
                            ),
                            child: Icon(Icons.update,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(_l.translate('legend waiting'),
                              style: _t.textTheme.bodyText2,
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red
                            ),
                            child: Icon(Icons.cancel,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(_l.translate('legend rejected'),
                              style: _t.textTheme.bodyText2,
                            )
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green
                            ),
                            child: Icon(Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(_l.translate('legend approved'),
                              style: _t.textTheme.bodyText2,
                            )
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                      primary: false,
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: _photos.map((photo) =>
                          GridTile(
                              child: ImageCard(
                                icon: _iconFromStatus(photo.status),
                                working: _uploadingPhotos.contains(photo.id),
                                color: _colorFromStatus(photo.status),
                                onHelp: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(_l.translate('how take photo')),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(photo.helpText??''),
                                          SizedBox(height: 10),
                                          Text(_l.translate('example'),
                                            style: _t.textTheme.button,
                                          ),
                                          SizedBox(height: 10),
                                          Image.network(photo.helpExampleUrl,
                                            fit: BoxFit.fitWidth,
                                          )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(_l.translate('accept')),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    ));
                                },
                                image: _resourceCache.get(
                                  id: photo.id,
                                  resourceUrl: photo.resourceUrl,
                                  localCache: photo.localCache,
                                  dateTime: photo.dateTime
                                ),
                                title: Text(photo.description,
                                  style: _t.textTheme.button,
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () async {
                                  if (photo.status == ResourceStatus.empty||
                                      photo.status == ResourceStatus.rejected) {
                                    var photoFile = await _picker.getImage(
                                        source: ImageSource.camera);
                                    if (photoFile != null) {
                                      _photoBloc.add(UploadPhoto(
                                          photo,
                                          await photoFile.readAsBytes()));
                                    }
                                  }
                                },
                              )
                          )
                      ).toList()
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Visibility(
                      visible: _photos.length > 0 && !(_photos.any((photo) =>
                          photo.status != ResourceStatus.approved)),
                      child: RaisedButton(
                        child: Text(_l.translate('continue').toUpperCase(),
                            style: _t.accentTextTheme.button
                        ),
                        color: _t.accentColor,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.inspectionStep3);
                        },
                      ),
                    )
                  )
                ]
            );
          } else {
            return Container();
          }
        },
      )
    );
  }
}