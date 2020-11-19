
import 'package:flutter/material.dart';
import 'package:legall_rimac_virtual/data_helper.dart';

class BrandModel {
  String id;
  String brandName;
  List<String> models;

  BrandModel({this.id,@required this.brandName,this.models});

  factory BrandModel.fromJSON({String id, dynamic data}) {
    return BrandModel(
      id: id,
      brandName: data['brand_name'],
      models: typedList<String>(data['models'])
    );
  }
}