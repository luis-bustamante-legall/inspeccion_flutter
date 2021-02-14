import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
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
  var scrollController = ScrollController();
  ResourceCache _resourceCache = ResourceCache();

  @override
  void initState() {
    super.initState();
    _settingsRepository = RepositoryProvider.of<SettingsRepository>(context);
    _photoBloc = BlocProvider.of<PhotoBloc>(context);
    _photoBloc.add(LoadPhotos(
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

  Widget _buildLoadedState(BuildContext context, PhotoState state) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);
    var messenger = Scaffold.of(context);
    var photos = state.photos??[];
    if (state is PhotoUploadCompleted) {
      if (!state.success) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          duration: Duration(minutes: 5),
          backgroundColor: _t.accentColor,
          padding: EdgeInsets.zero,
          content: ListTile(
            leading: CircularProgressIndicator(),
            title: Text(_l.translate('problems uploading photos'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
      }
    }
    else if (state is PhotoLoaded) {
      if (!state.success) {
        print(state.errorMessage);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          duration: Duration(seconds: 4),
          backgroundColor: Colors.red,
          content: ListTile(
            contentPadding: EdgeInsets.all(5),
            leading: Icon(Icons.announcement_rounded),
            title: Text(_l.translate('problems loading photos'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
      }
    }
    return ListView(
        padding: EdgeInsets.all(20),
        controller: scrollController,
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
          GridView.builder(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2),
            itemCount: photos.length,
            primary: false,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              var photo = photos.elementAt(index);
              return GridTile(
                  child: ImageCard(
                    icon: _iconFromStatus(photo.status),
                    working: photo.status == ResourceStatus.uploading,
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
                                _resourceCache.loadImageHelp(photo.helpExampleUrl)
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
                    image: photo.resourceUrl != null ?
                      CachedNetworkImageProvider(photo.resourceUrl,
                        cacheKey: 'image_${photo.id}_${photo.dateTime?.millisecondsSinceEpoch}'
                      ): null,
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
              );
            }
          ),
          /*GridView.count(
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 2,
              children: photos.map((photo) =>
                  GridTile(
                      child: ImageCard(
                        icon: _iconFromStatus(photo.status),
                        working: photo.status == ResourceStatus.uploading,
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
                                    _resourceCache.loadImageHelp(photo.helpExampleUrl)
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
                        image: null,
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
          )*/
          Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: photos.length > 0 && !(photos.any((photo) =>
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
          return _buildLoadedState(context, state);
        },
      )
    );
  }
}