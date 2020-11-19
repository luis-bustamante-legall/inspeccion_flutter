import 'package:legall_rimac_virtual/data_helper.dart';

class ChatModel {
  String inspectionId;
  DateTime dateTime;
  ChatSource source;
  bool read;
  String body;

  ChatModel({
    this.inspectionId,
    this.dateTime,
    this.source,
    this.read,
    this.body
  });

  factory ChatModel.fromJSON(Map<String,dynamic> json) {
    return ChatModel(
      inspectionId: json['inspection_id'],
      dateTime: dateTimeOrNull(json['datetime']),
      source: enumFromMap(ChatSource.values, json['source']),
      read: json['read']??false,
      body: json['body']
    );
  }

  Map<String,dynamic> toJSON() {
    return {
      'inspection_id': inspectionId,
      'datetime': dateTime??DateTime.now(),
      'source': enumToMap(source),
      'read': read??false,
      'body': body
    };
  }
}

enum ChatSource {
  inspector,
  insured,
  system
}