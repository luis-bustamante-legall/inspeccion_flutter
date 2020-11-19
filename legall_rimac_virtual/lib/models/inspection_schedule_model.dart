
import 'package:legall_rimac_virtual/data_helper.dart';

class InspectionSchedule {
  DateTime dateTime;
  InspectionScheduleType type;

  InspectionSchedule({
    this.type,
    this.dateTime
  });

  factory InspectionSchedule.fromJSON(Map<String,dynamic> json) {
    return InspectionSchedule(
      type: enumFromMap(InspectionScheduleType.values, json['type']),
      dateTime: dateTimeOrNull(json['datetime'])
    );
  }

  Map<String,dynamic> toJSON() {
    return {
      'type': enumToMap(type),
      'datetime': dateTime
    };
  }
}

enum InspectionScheduleType { scheduled,rescheduled,complete }

