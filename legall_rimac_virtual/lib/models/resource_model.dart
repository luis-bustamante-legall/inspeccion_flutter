import 'package:flutter/material.dart';

abstract class ResourceModel {
  String inspectionId;
  String description;
  String helpText;
  String helpExampleUrl;
  DateTime dateTime;
  String resourceUrl;
  ResourceStatus status;

  @protected
  ResourceModel({
    this.inspectionId,
    this.description,
    this.helpText,
    this.helpExampleUrl,
    this.dateTime,
    this.resourceUrl,
    this.status
  });
}

enum ResourceStatus {
  empty,
  uploaded,
  approved,
  rejected,
  uploading
}