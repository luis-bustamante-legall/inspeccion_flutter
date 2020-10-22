import 'package:flutter/material.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';

class InspectionScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionScreenState();
}

class InspectionScreenState extends State<InspectionScreen> {

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    if (model.status == InspectionStatus.scheduled) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Inspección Programada'),
        ),
        body: ListView(

        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Inspección Programada'),
        ),
        body: ListView(

        ),
      );
    }

  }
}