import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:intl/intl.dart';

import '../routes.dart';

class InspectionScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionScreenState();
}

class InspectionScreenState extends State<InspectionScreen> {
  final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  ThemeData _t;

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    _t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inspección Programada'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Estimado asegurado, usted tiene programada su inspección virtual en la fecha'),
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(_dateTimeFormat.format(model.dateTime),
                style: _t.textTheme.headline6,
              ),
            ),
          ),
          Text('Puedes solicitar una reprogramación para esta inspección previa coordinación',
            textAlign: TextAlign.center,
          ),
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text('REPROGRAMAR',
                textAlign: TextAlign.center,
                style: _t.textTheme.headline6.copyWith(
                  color: Colors.indigo,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  child: Text('Datos del Asegurado',
                    style: _t.textTheme.subtitle1,
                  ),
                  padding: EdgeInsets.all(15),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Nombre'),
                        subtitle: Text(model.fullName??'-')
                      ),
                      Divider(indent: 15,endIndent: 15,height: 2,),
                      ListTile(
                        title: Text('Contratante'),
                        subtitle: Text(model.contractor??'-')
                      ),
                      Divider(indent: 15,endIndent: 15,height: 1,),
                      ListTile(
                        title: Text('Detalles de contacto'),
                        subtitle: Text(model.contactDetails??'-')
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  child: Text('Datos del Vehiculo',
                    style: _t.textTheme.subtitle1,
                  ),
                  padding: EdgeInsets.all(15),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                          title: Text('Marca'),
                          subtitle: Text(model.brand??'-')
                      ),
                      Divider(indent: 15,endIndent: 15,height: 2,),
                      ListTile(
                          title: Text('Modelo'),
                          subtitle: Text(model.model??'-')
                      ),
                      Divider(indent: 15,endIndent: 15,height: 1,),
                      ListTile(
                          title: Text('Placa'),
                          subtitle: Text(model.plate??'-')
                      ),
                      Divider(indent: 15,endIndent: 15,height: 1,),
                      ListTile(
                          title: Text('Dirección'),
                          subtitle: Text(model.address??'-')
                      ),
                      Divider(indent: 15,endIndent: 15,height: 1,),
                      ListTile(
                          title: Text('Correo electronico'),
                          subtitle: Text(model.email??'-')
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.inspectionStep1,arguments: model);
                    },
                    color: _t.accentColor,
                    child: Text('INICIAR INSPECIÓN',
                      style: _t.accentTextTheme.button,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}