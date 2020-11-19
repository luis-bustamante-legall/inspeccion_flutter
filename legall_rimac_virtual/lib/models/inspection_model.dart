
import 'package:legall_rimac_virtual/data_helper.dart';
import 'package:legall_rimac_virtual/models/inspection_schedule_model.dart';

class InspectionModel {
  //Inspection data
  String inspectionId;

  //App configuration
  String appColor;
  String insuranceCompany;
  bool showLegallLogo;
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
    bool showLegallLogo,
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
      insuranceCompany: json['insurance_company'],
      showLegallLogo: json['show_legall_logo']??true,
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
      'status': enumToMap(status),
    };
  }

  Map<String,dynamic> toJSONWithInspectionData() {
    return {
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
  onStep1,
  onStep2,
  onStep3,
  onStep4,
  complete
}