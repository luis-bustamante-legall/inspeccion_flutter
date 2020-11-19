import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/photo_bloc.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/photo_model.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/routes.dart';
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
  List<PhotoModel> _photos = [];
  List<String> _uploadingPhotos = [];

  @override
  void initState() {
    super.initState();
    _settingsRepository = RepositoryProvider.of<SettingsRepository>(context);
    _photoBloc = BlocProvider.of<PhotoBloc>(context);
    _photoBloc.add(LoadPhoto(
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

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_l.translate('inspection step',arguments: {"step": "3" })),
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
                    var messenger = ScaffoldMessenger.of(context);
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
                    Text(_l.translate('add photos')),
                    SizedBox(height: 20,),
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
                                  image: photo.resourceUrl != null ? NetworkImage(photo.resourceUrl): null,
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
                        ).toList()..add(GridTile(
                          child: Card(
                            child: InkWell(
                              onTap: () async {
                                TextEditingController textController = TextEditingController();
                                var description = await showDialog<String>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(_l.translate('photo description')),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: textController,
                                          decoration: InputDecoration(
                                            hintText: _l.translate('description'),
                                          ),
                                        )
                                      ],
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
                                          if (textController.text.isNotEmpty) {
                                            Navigator.of(context).pop(
                                              textController.text
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  ));
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
                        ))
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Visibility(
                          visible: !(_photos.any((photo) =>
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