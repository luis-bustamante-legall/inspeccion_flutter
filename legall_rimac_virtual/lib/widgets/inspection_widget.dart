import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';

class InspectionWidget extends StatelessWidget {
  final InspectionModel model;
  final InspectionSchedule schedule;
  final Function() onTap;

  final _dayFormat = new DateFormat('dd');
  final _monthFormat = new DateFormat('MMM');
  final _yearFormat = new DateFormat('yyyy');
  final _timeFormat = new DateFormat.jm();

  Color _colorFromSchedule() {
    switch(schedule.type) {
      case InspectionScheduleType.scheduled:
        return Color.fromARGB(255, 41, 113, 48);
      case InspectionScheduleType.rescheduled:
        return Color.fromARGB(255, 185, 42 , 44);
      case InspectionScheduleType.complete:
        return Color.fromARGB(255, 115, 114, 28);
      default:
        return Colors.purple;
    }
  }

  String _scheduleText(BuildContext context) {
    AppLocalizations _l = AppLocalizations.of(context);
    switch(schedule.type) {
      case InspectionScheduleType.complete:
        return _l.translate('complete');
      case InspectionScheduleType.scheduled:
        return _l.translate('scheduled');
      case InspectionScheduleType.rescheduled:
        return _l.translate('rescheduled');
      case InspectionScheduleType.unconfirmed:
        return _l.translate('unconfirmed');
      default:
        return '';
    }
  }

  InspectionWidget({
    @required this.model,
    @required this.schedule,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    ThemeData _t = Theme.of(context);
    return Card(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.plate??'-',
                        style: _t.textTheme.headline6,
                        overflow: TextOverflow.ellipsis
                      ),
                      Text('${model.brandName} - ${model.modelName}',
                        style: _t.textTheme.button,
                        overflow: TextOverflow.ellipsis
                      ),
                      SizedBox( height: 10),
                      Text(model.insuredName??'-',
                        overflow: TextOverflow.ellipsis
                      )
                    ],
                  )
              )
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        topRight: Radius.circular(5)
                    ),
                    color: _colorFromSchedule(),
                  ),
                  child: SizedBox(
                      width: 100,
                      child: Center(
                        child: Text(_scheduleText(context).toUpperCase(),
                            style: _t.accentTextTheme.button
                        ),
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(_dayFormat.format(schedule.dateTime),
                            style: _t.textTheme.headline4,
                          ),
                          Column(
                            children: [
                              Text(_monthFormat.format(schedule.dateTime).toUpperCase(),
                                style: _t.textTheme.button,
                              ),
                              Text(_yearFormat.format(schedule.dateTime),
                                style: _t.textTheme.button,
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                            size: 15,
                          ),
                          SizedBox( width: 5,),
                          Text(_timeFormat.format(schedule.dateTime))
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }
}
