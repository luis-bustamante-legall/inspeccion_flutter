
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';

class InspectionModel {
  //Inspection data
  String inspectionId;
  String additionalInfo;
  GeoPoint location;

  //App configuration
  String appColor;
  String insuranceCompany;
  bool showLegallLogo;
  String titleToShow;
  InspectionStatus status;

  //Vehicle
  String plate;
  String brandId;
  String brandName;
  String modelName;

  //Insured data
  String insuredName;
  String contractorName;
  String contactAddress;
  String contactEmail;
  String contactPhone;

  List<InspectionSchedule> schedule;

  InspectionModel({
    this.inspectionId,
    this.appColor,
    this.titleToShow,
    this.additionalInfo,
    this.location,
    this.insuranceCompany,
    this.showLegallLogo,
    this.status,
    this.plate,
    this.brandId,
    this.brandName,
    this.modelName,
    this.insuredName,
    this.contractorName,
    this.contactAddress,
    this.contactEmail,
    this.contactPhone,
    this.schedule
  });

  InspectionModel copyWith({
    String inspectionId,
    String appColor,
    String insuranceCompany,
    String titleToShow,
    bool showLegallLogo,
    String additionalInfo,
    GeoPoint location,
    InspectionStatus status,
    String plate,
    String brandId,
    String brandName,
    String modelName,
    String insuredName,
    String contractorName,
    String contactAddress,
    String contactEmail,
    String contactPhone,
    List<InspectionSchedule> schedule
  }) => InspectionModel(
    inspectionId: inspectionId??this.inspectionId,
    appColor: appColor??this.appColor,
    insuranceCompany: insuranceCompany??this.insuranceCompany,
    showLegallLogo: showLegallLogo??this.showLegallLogo,
    titleToShow: titleToShow??this.titleToShow,
    additionalInfo: additionalInfo??this.additionalInfo,
    location: location??this.location,
    status: status??this.status,
    plate: plate??this.plate,
    brandId: brandId??this.brandId,
    brandName: brandName??this.brandName,
    modelName: modelName??this.modelName,
    insuredName: insuredName??this.insuredName,
    contractorName: contractorName??this.contractorName,
    contactAddress: contactAddress??this.contactAddress,
    contactEmail: contactEmail??this.contactEmail,
    contactPhone: contactPhone??this.contactPhone,
    schedule: schedule??this.schedule
  );

  factory InspectionModel.fromJSON(Map<String,dynamic> json,{String id}) {
    return InspectionModel(
      inspectionId: id,
      appColor: json['app_color'],
      titleToShow: json['title_to_show'],
      insuranceCompany: json['insurance_company'],
      showLegallLogo: json['show_legall_logo']??false,
      additionalInfo: json['additional_information'],
      location: json['location'],
      status: enumFromMap(InspectionStatus.values, json['status']) ?? InspectionStatus.onHold,
      plate: json['plate'],
      brandId: json['brand_id'],
      brandName: json['brand_name'],
      modelName: json['model_name'],
      insuredName: json['insured_name'],
      contractorName: json['contractor_name'],
      contactAddress: json['contact_address'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      schedule: (typedList<Map<String,dynamic>>(json['schedule'])??[])
          .map((sch) => InspectionSchedule.fromJSON(sch)).toList()
    );
  }

  Map<String,dynamic> toJSONWithUpdateStatus() {
    return {
      'additional_information': additionalInfo,
      'schedule': schedule.map((sch) => sch.toJSON()).toList(),
      'status': enumToMap(status),
    };
  }

  Map<String,dynamic> toJSONWithInspectionData() {
    return {
      'location': location,
      'brand_id': brandId,
      'brand_name': brandName,
      'model_name': modelName,
      'contact_address': contactAddress,
      'contact_email': contactEmail,
      'contact_phone': contactPhone
    };
  }

  Map<String,dynamic> toJSONWithSchedule() {
    return {
      'schedule': schedule.map((sch) => sch.toJSON()).toList()
    };
  }
}


enum InspectionStatus {
  onHold,
  available,
  complete
}