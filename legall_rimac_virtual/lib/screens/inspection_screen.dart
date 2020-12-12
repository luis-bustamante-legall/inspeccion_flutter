import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/blocs/blocs.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:intl/intl.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';
import 'package:location/location.dart';

import '../routes.dart';

class InspectionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InspectionScreenState();
}

class InspectionScreenState extends State<InspectionScreen> {
  final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  InspectionBloc _inspectionBloc;

  Future<LocationData> _getLocation() async {
    AppLocalizations _l = AppLocalizations.of(context);
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          child: AlertDialog(
            title: Text(_l.translate('geolocation unavailable')),
            content: Text(_l.translate('geolocation service off')),
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
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        await showDialog(
            context: context,
            barrierDismissible: false,
            child: AlertDialog(
              title: Text(_l.translate('geolocation unavailable')),
              content: Text(_l.translate('geolocation permission denied')),
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
        return null;
      }
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        child: SimpleDialog(
          title: Text(_l.translate('locating')),
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              )
            )
          ],
        )
    );
    var result = await location.getLocation();
    Navigator.pop(context);
    return result;
  }

  @override
  void initState() {
    super.initState();
    _inspectionBloc = BlocProvider.of<InspectionBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);
    _t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_l.translate('scheduled inspection')),
      ),
      body: BlocBuilder<InspectionBloc,InspectionState>(
        builder: (context,state) {
          if (state is InspectionLoaded) {
            var schedule = state.inspectionModel.schedule.last;
            var model = state.inspectionModel;
            return ListView(
              padding: EdgeInsets.all(20),
              children: [
                Text(_l.translate('inspection datetime')),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(_dateTimeFormat.format(schedule.dateTime),
                      style: _t.textTheme.headline6,
                    ),
                  ),
                ),
                Text(_l.translate('request reschedule inspection'),
                  textAlign: TextAlign.center,
                ),
                Center(
                  child: RaisedButton(
                      onPressed: () async {
                        var currentDate = DateTime.now();
                        DateTime datePicked = await showDatePicker(
                            context: context,
                            initialDate: currentDate,
                            initialDatePickerMode: DatePickerMode.day,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365))
                        );
                        if (datePicked != null) {
                          TimeOfDay timePicked =  await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(currentDate),
                          );
                          if (timePicked != null) {
                            model.schedule.forEach((sch) {
                              sch.type = InspectionScheduleType
                                  .rescheduled;
                            });
                            model.schedule.add(InspectionSchedule(
                                dateTime: DateTime(
                                    datePicked.year,
                                    datePicked.month,
                                    datePicked.day,
                                    timePicked.hour,
                                    timePicked.minute
                                ),
                                type: InspectionScheduleType
                                    .scheduled
                            ));
                            _inspectionBloc.add(
                                UpdateInspectionData(
                                    model,
                                    UpdateInspectionType.schedule
                                )
                            );
                          }
                        }
                      },
                      color: _t.accentColor,
                      child: Text(_l.translate('reschedule').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: _t.accentTextTheme.button
                      )
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        child: Text(_l.translate('insured data'),
                          style: _t.textTheme.subtitle1,
                        ),
                        padding: EdgeInsets.all(15),
                      ),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                                title: Text(_l.translate('name')),
                                subtitle: Text(model.insuredName??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 2,),
                            ListTile(
                                title: Text(_l.translate('contractor')),
                                subtitle: Text(model.contractorName??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                                title: Text(_l.translate('contact details')),
                                subtitle: Text(model.contactEmail??'-')
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        child: Text(_l.translate('vehicle data'),
                          style: _t.textTheme.subtitle1,
                        ),
                        padding: EdgeInsets.all(15),
                      ),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                                title: Text(_l.translate('brand')),
                                subtitle: Text(model.brandName??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 2,),
                            ListTile(
                                title: Text(_l.translate('model')),
                                subtitle: Text(model.modelName??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                                title: Text(_l.translate('plate')),
                                subtitle: Text(model.plate??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                                title: Text(_l.translate('contact address')),
                                subtitle: Text(model.contactAddress??'-')
                            ),
                            Divider(indent: 15,endIndent: 15,height: 1,),
                            ListTile(
                                title: Text(_l.translate('contact email')),
                                subtitle: Text(model.contactEmail??'-')
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BlocListener<InspectionBloc,InspectionState>(
                          listener: (context,state) {
                            if (state is InspectionUpdated) {
                              if (state.success && state.type == UpdateInspectionType.data) {
                                Navigator.pushNamed(context, AppRoutes.inspectionStep1,arguments: state.inspectionModel);
                              } else if (state.type == UpdateInspectionType.data) {
                                Future.delayed(Duration(milliseconds: 100),() {
                                  var messenger = Scaffold.of(context);
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(SnackBar(
                                    duration: Duration(seconds: 4),
                                    backgroundColor: Colors.red,
                                    content: ListTile(
                                      leading: Icon(Icons.announcement_rounded),
                                      title: Text(_l.translate('problems reschedule inspection'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ));
                                });
                              }
                            }
                          },
                          child: RaisedButton(
                            onPressed: model.status != InspectionStatus.onHold ? () async {
                              var location = await _getLocation();
                              if (location != null) {
                                var newModel = model.copyWith(
                                    location: GeoPoint(location.latitude,location.longitude)
                                );
                                _inspectionBloc.add(UpdateInspectionData(
                                    newModel, UpdateInspectionType.data));
                              }
                            }: null,
                            color: _t.accentColor,
                            child: Text(_l.translate('start inspection').toUpperCase(),
                              style: _t.accentTextTheme.button,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}