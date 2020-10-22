
import 'package:flutter/material.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/inspection_widget.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ThemeData _t;

  @override
  Widget build(BuildContext context) {
    _t = Theme.of(context);

    var _models = [
      InspectionModel(
        status: InspectionStatus.complete,
        dateTime: DateTime.now(),
        plate: 'MG 23456',
        brand: 'Nissan',
        model: 'NP300',
        fullName: 'Hilda Patricia Perez Delgado',
      ),
      InspectionModel(
        status: InspectionStatus.scheduled,
        dateTime: DateTime.now(),
        plate: 'MG 23456',
        brand: 'Nissan',
        model: 'NP300',
        fullName: 'Hilda Patricia Perez Delgado',
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Rimac Virtual'),
        actions: [
          FlatButton(
            onPressed: () {

            },
            child: Icon(Icons.add,
                color: _t.accentTextTheme.button.color,
            )
          )
        ],
      ),
      drawer: Drawer(

      ),
      body: ListView(
        children: <Widget>[]
          ..addAll(_models.map((model) =>
            InspectionWidget(
              model: model,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.inspection,arguments: model);
              }
            )
          ))..add(
            InkWell(
              onTap: () {
                //
              },
              child:Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Icon(Icons.add,
                      color: Colors.indigo,
                    ),
                    Text('Agendar una nueva inspección',
                      style: TextStyle(
                          color: Colors.indigo
                      ),
                    )
                  ],
                ),
              )
            )
          )
        )
      );
  }
}