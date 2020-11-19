import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';

class PhotoModel extends ResourceModel {
  String id;
  String group;
  PhotoType type;
  PhotoCreator creator;

  PhotoModel({
    this.id,
    String inspectionId,
    String description,
    this.group,
    String helpText,
    String helpExampleUrl,
    DateTime dateTime,
    String resourceUrl,
    ResourceStatus status,
    this.type,
    this.creator
  }): super(
    inspectionId:inspectionId,
    description: description,
    helpText: helpText,
    helpExampleUrl: helpExampleUrl,
    dateTime: dateTime,
    resourceUrl: resourceUrl,
    status: status
  );

  factory PhotoModel.fromJSON(Map<String,dynamic> json,{String id}) {
    return PhotoModel(
        id: id,
        inspectionId: json['inspection_id'],
        description: json['description'],
        group: json['group'],
        helpText: json['help_text'],
        helpExampleUrl: json['help_example_url'],
        dateTime: dateTimeOrNull(json['datetime']),
        resourceUrl: json['resource_url'],
        status: enumFromMap(ResourceStatus.values, json['status']),
        type: enumFromMap(PhotoType.values, json['type']),
        creator: enumFromMap(PhotoCreator.values, json['creator'])
    );

  }

  Map<String,dynamic> toJSON() {
    return {
      'inspection_id': inspectionId,
      'description': description,
      'group': group,
      'help_text': helpText,
      'help_example_url': helpExampleUrl,
      'datetime': dateTime,
      'resource_url': resourceUrl,
      'status': enumToMap(status),
      'type': enumToMap(type),
      'creator': enumToMap(creator)
    };
  }
}

enum PhotoType {
  initial,
  predefined,
  additional
}

enum PhotoCreator {
  inspector,
  insured
}
