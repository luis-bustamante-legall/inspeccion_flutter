

class InspectionModel {
  //Inspection data
  InspectionStatus status;
  DateTime dateTime;

  //Insured data
  String fullName;
  String contractor;
  String contactDetails;

  //Vehicle data
  String plate;
  String brand;
  String model;
  String address;
  String email;

  InspectionModel({
    this.status,
    this.dateTime,
    this.fullName,
    this.contractor,
    this.contactDetails,
    this.plate,
    this.brand,
    this.model,
    this.address,
    this.email
  });

}

enum InspectionStatus { scheduled,complete }