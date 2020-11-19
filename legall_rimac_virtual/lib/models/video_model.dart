import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/models/resource_model.dart';

class VideoModel extends ResourceModel {
  String id;

  VideoModel({
    this.id,
    String inspectionId,
    String description,
    String helpText,
    String helpExampleUrl,
    DateTime dateTime,
    String resourceUrl,
    ResourceStatus status
  }): super(
      inspectionId:inspectionId,
      description: description,
      helpText: helpText,
      helpExampleUrl: helpExampleUrl,
      dateTime: dateTime,
      resourceUrl: resourceUrl,
      status: status
  );

  factory VideoModel.fromJSON(Map<String,dynamic> json,{String id}) {
    return VideoModel(
        id: id,
        inspectionId: json['inspection_id'],
        description: json['description'],
        helpText: json['help_text'],
        helpExampleUrl: json['help_example_url'],
        dateTime: dateTimeOrNull(json['datetime']),
        resourceUrl: json['resource_url'],
        status: enumFromMap(ResourceStatus.values, json['status'])
    );
  }

  Map<String,dynamic> toJSON() {
    return {
      'inspection_id': inspectionId,
      'description': description,
      'help_text': helpText,
      'help_example_url': helpExampleUrl,
      'datetime': dateTime,
      'resource_url': resourceUrl,
      'status': enumToMap(status)
    };
  }
}
