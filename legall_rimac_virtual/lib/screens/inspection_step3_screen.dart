import 'dart:io';
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
import 'package:legall_rimac_virtual/image_thumbnail.dart';
import 'package:legall_rimac_virtual/widgets/chat_button.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legall_rimac_virtual/widgets/phone_call_button.dart';


class InspectionStep3Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep3ScreenState();
}

class InspectionStep3ScreenState extends State<InspectionStep3Screen> {
  final ImagePicker _picker = ImagePicker();
  SettingsRepository _settingsRepository;
  PhotoBloc _photoBloc;

  ResourceCache _resourceCache = ResourceCache();


  Future<String> _showTextDialog({String title,String label,int maxLength,int maxLines, String Function(String) validator}) async {
    AppLocalizations _l = AppLocalizations.of(context);
    TextEditingController textController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                    controller: textController,
                    maxLength: maxLength,
                    maxLengthEnforced: true,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      hintText: label,
                    ),
                    validator: validator ?? (newText) =>
                    newText.trim().isEmpty ? _l.translate('required field'):
                    newText.length > (maxLength??1024) ? _l.translate('too long'): null
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(_l.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(_l.translate('save')),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context).pop(
                      textController.text
                  );
                }
              },
            )
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    _settingsRepository = RepositoryProvider.of<SettingsRepository>(context);
    _photoBloc = BlocProvider.of<PhotoBloc>(context);
    _photoBloc.add(LoadPhotos(
        _settingsRepository.getInspectionId(),
        PhotoType.additional));
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
        Future.delayed(Duration(milliseconds: 50),() {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(SnackBar(
            duration: Duration(seconds: 4),
            backgroundColor: Colors.red,
            content: ListTile(
              contentPadding: EdgeInsets.all(5),
              leading: Icon(Icons.announcement_rounded),
              title: Text(_l.translate('problems uploading photos'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ));
        });
      }
    }
    else if (state is PhotoLoaded) {
      if (!state.success) {
        print(state.errorMessage);
        Future.delayed(Duration(milliseconds: 50),() {
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
        });
      }
    }
    return Column(
        children: [
          Flexible(
            child: GridView.builder(
                padding: EdgeInsets.all(15),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2),
                primary: false,
                shrinkWrap: true,
                itemCount: photos.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == photos.length) {
                    return GridTile(
                      child: Card(
                        child: InkWell(
                          onTap: () async {
                            var description = await _showTextDialog(
                                maxLength: 100,
                                label: _l.translate('description'),
                                title:  _l.translate('photo description')
                            );

                            if (description != null) {
                              _photoBloc.add(AddPhoto(
                                  PhotoModel(
                                    inspectionId: _settingsRepository.getInspectionId(),
                                    description: description,
                                    creator: PhotoCreator.insured,
                                    status: ResourceStatus.empty,
                                    type: PhotoType.additional,
                                    dateTime: DateTime.now(),
                                  )
                              ));
                            }
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add,
                                  color: _t.accentColor,
                                ),
                                Text(_l.translate('new photo'),
                                  style: _t.textTheme.headline6.copyWith(
                                    color: _t.accentColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  var photo = photos.elementAt(index);
                  return GridTile(
                      child: ImageCard(
                        icon: _iconFromStatus(photo.status),
                        working: photo.status == ResourceStatus.uploading,
                        color: _colorFromStatus(photo.status),
                        image: photo.resourceUrl != null ?
                        CachedNetworkImageProvider(ImageThumbnail.getUrl(photo.resourceUrl),
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
                                  photo,File(photoFile.path)));
                            }
                          }
                        },
                      )
                  );
                }
            )
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Align(
                alignment: Alignment.centerRight,
                child: Visibility(
                  visible: !(photos.any((photo) =>
                  photo.status != ResourceStatus.approved)),
                  child: RaisedButton(
                    child: Text(_l.translate('continue').toUpperCase(),
                        style: _t.accentTextTheme.button
                    ),
                    color: _t.accentColor,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.inspectionStep4);
                    },
                  ),
                )
            ),
          )
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_l.translate('inspection step',arguments: {"step": "3" })),
          actions: [
            IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(_l.translate('help')),
                      content: Text(_l.translate('add photos')),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(_l.translate('accept')),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    )
                );
              }
            ),
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