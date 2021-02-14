import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/models.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legall_rimac_virtual/resource_cache.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';

import '../routes.dart';

class ScheduleInspectionStep2 extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ScheduleInspectionStep2State();
}

class ScheduleInspectionStep2State extends State<ScheduleInspectionStep2> {
  final ImagePicker _picker = ImagePicker();
  final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  InspectionBloc _inspectionBloc;
  SettingsRepository _settingsRepository;
  PhotoBloc _photoBloc;
  ResourceCache _resourceCache = ResourceCache();
  DateTime _datePicked;
  
  @override
  void initState() {
    super.initState();
    _settingsRepository = RepositoryProvider.of<SettingsRepository>(context);
    _inspectionBloc = BlocProvider.of<InspectionBloc>(context);
    _photoBloc = BlocProvider.of<PhotoBloc>(context);
    _photoBloc.add(LoadPhotos(
        _settingsRepository.getInspectionId(),
        PhotoType.initial));
  }

  DateTime _getDateTime(List<InspectionSchedule> schedule) {
    if (_datePicked != null)
      return _datePicked;
    else if (schedule != null && schedule.length > 0)
      return schedule.last.dateTime ?? DateTime.now();
    else
      return DateTime.now();
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

  Widget _buildLoadedState(BuildContext context, PhotoState state, InspectionState inspectionState) {
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
    Map<String,List<PhotoModel>> photoGroups = {};
    for(var photo in photos) {
      if (photoGroups.containsKey(photo.group)) {
        photoGroups[photo.group].add(photo);
      } else {
        photoGroups[photo.group] = [photo];
      }
    }
    return Column(
        children: photoGroups.entries.map((entry) {
          var gridView = GridView.count(
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 2,
              children: entry.value.map((photo) =>
                  GridTile(
                      child: ImageCard(
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
                                    _resourceCache.loadImageHelp(
                                        photo.helpExampleUrl)
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
                        icon: _iconFromStatus(photo.status),
                        working: photo.status == ResourceStatus.uploading,
                        color: _colorFromStatus(photo.status),
                        image:  photo.resourceUrl != null ?
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
                  )
              ).toList()
          );
          if (entry.key != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(entry.key,
                      style: _t.textTheme.subtitle1
                  ),
                ),
                gridView
              ],
            );
          } else {
            return gridView;
          }
        }).toList()..add(Column(
          children: [
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: !photoGroups.entries.any((map) => map.value.any((photo) => photo.status != ResourceStatus.approved)),
                child: RaisedButton(
                  color: _t.accentColor,
                  child: BlocListener<InspectionBloc,InspectionState>(
                    listener: (context,newInspectionState) async {
                      if (newInspectionState is InspectionUpdated) {
                        if (newInspectionState.success) {
                          await showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: AlertDialog(
                                title: Text(_l.translate('schedule inspection')),
                                content: Text(_l.translate('the schedule was confirmed')),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(_l.translate('ok'))
                                  )
                                ],
                              )
                          );
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.home,
                                  (Route<
                                  dynamic> route) => false);

                        }
                      }
                    },
                    child: Text(_l.translate('schedule inspection').toUpperCase(),
                      style: _t.accentTextTheme.button,
                    ),
                  ),
                  onPressed: () {
                    if (inspectionState is InspectionLoaded) {
                      var schedule = inspectionState
                          .inspectionModel.schedule;
                      if (schedule.isEmpty) {
                        schedule.add(InspectionSchedule(
                            dateTime: _datePicked,
                            type: InspectionScheduleType
                                .scheduled
                        ));
                      } else {
                        schedule.last.type = InspectionScheduleType
                            .scheduled;
                        schedule.last.dateTime = _getDateTime(inspectionState
                            .inspectionModel.schedule);
                      }
                      var inspectionModel = inspectionState
                          .inspectionModel.copyWith(
                          schedule: schedule
                      );
                      _inspectionBloc.add(
                          UpdateInspectionData(
                              inspectionModel,
                              UpdateInspectionType.schedule
                          ));
                    }
                  },
                ),
              ),
            )
          ],
        ))
    );
  }


  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_l.translate('scheduled inspection step',arguments:  { "step": "2" })),
        ),
        body: BlocBuilder<InspectionBloc,InspectionState>(
            builder: (context,inspectionState) {
              if (inspectionState is InspectionLoaded) {
                print(inspectionState.inspectionModel.plate);
                return ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${inspectionState.inspectionModel?.brandName??'-'} - ${inspectionState.inspectionModel?.modelName??'-'}',
                                    style: _t.textTheme.button,
                                  ),
                                  SizedBox( height: 10),
                                  Text(inspectionState.inspectionModel?.insuredName??'-')
                                ],
                              )
                            ],
                          ),
                          Text(inspectionState.inspectionModel?.plate??'-',
                            style: _t.textTheme.headline4.copyWith(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Card(
                      child: ListTile(
                        title: Text(_l.translate('pick datetime')),
                        subtitle: Text(_dateTimeFormat.format(_getDateTime(inspectionState.inspectionModel?.schedule))),
                        trailing: Icon(Icons.navigate_next,
                            size: 35
                        ),
                        onTap: () async {
                          DateTime oldDateTime = _getDateTime(inspectionState.inspectionModel?.schedule);
                          DateTime datePicked = await showDatePicker(
                            context: context,
                            initialDate: _getDateTime(inspectionState.inspectionModel?.schedule),
                            initialDatePickerMode: DatePickerMode.day,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365))
                          );
                          if (datePicked != null) {
                            TimeOfDay timePicked =  await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(oldDateTime),
                            );
                            if (timePicked != null) {
                              setState(() {
                                _datePicked =  DateTime(
                                    datePicked.year,
                                    datePicked.month,
                                    datePicked.day,
                                    timePicked.hour,
                                    timePicked.minute
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),
                    BlocBuilder<PhotoBloc,PhotoState>(
                      builder: (context,state) {
                        return _buildLoadedState(context, state, inspectionState);
                      }
                    )
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
        )
    );
  }
}