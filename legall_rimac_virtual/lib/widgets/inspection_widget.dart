import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';

class InspectionWidget extends StatelessWidget {
  final InspectionModel model;
  final Function() onTap;

  final _dayFormat = new DateFormat('dd');
  final _monthFormat = new DateFormat('MMM');
  final _yearFormat = new DateFormat('yyyy');
  final _timeFormat = new DateFormat.jm();

  Color _colorFromStatus() {
    switch(model.status) {
      case InspectionStatus.complete:
        return Color.fromARGB(255, 41, 113, 48);
      case InspectionStatus.scheduled:
        return Color.fromARGB(255, 115, 114, 28);
      default:
        return Colors.black87;
    }
  }

  String _statusText() {
    switch(model.status) {
      case InspectionStatus.complete:
        return 'Completa';
      case InspectionStatus.scheduled:
        return 'Agendada';
      default:
        return '';
    }
  }

  InspectionWidget({
    @required this.model,
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
            Padding(
                padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.plate,
                      style: _t.textTheme.headline6,
                    ),
                    Text('${model.brand} - ${model.model}',
                      style: _t.textTheme.button,
                    ),
                    SizedBox( height: 10),
                    Text(model.fullName)
                  ],
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
                    color: _colorFromStatus(),
                  ),
                  child: SizedBox(
                      width: 100,
                      child: Center(
                        child: Text(_statusText().toUpperCase(),
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
                          Text(_dayFormat.format(model.dateTime),
                            style: _t.textTheme.headline4,
                          ),
                          Column(
                            children: [
                              Text(_monthFormat.format(model.dateTime).toUpperCase(),
                                style: _t.textTheme.button,
                              ),
                              Text(_yearFormat.format(model.dateTime),
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
                          Text(_timeFormat.format(model.dateTime))
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
