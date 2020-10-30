import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';
import 'package:image_picker/image_picker.dart';

class InspectionStep2Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep2ScreenState();
}

class InspectionStep2ScreenState extends State<InspectionStep2Screen> {
  ThemeData _t;
  final ImagePicker _picker = ImagePicker();

  final _photos = [
    'Frontal',
    'Posterior',
    'Lateral derecho',
    'Lateral izquierdo',
    'Consola',
    'Motor',
    'Llanta instalada',
    'Tacómetro',
    'PuertaPiloto',
    'Timón',
    'Radio',
    'A/C',
    'Cambio de llanta',
    'SOAT',
    'VIN de vehículo',
    'DNI Frontal',
    'DNI Reverso',
    'Tarjeta de propiedad Frontal',
    'Tarjeta de propiedad Reverso'];

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    _t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inspección Virtual - Paso 2'),
        actions: [
          IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                //TODO: pass chat ID
                Navigator.pushNamed(context, AppRoutes.chat,
                    arguments: ''
                );
              }
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Seleccione las fotos de su vehiculo para iniciar la inspección.'),
          SizedBox(height: 20,),
          GridView.count(
            primary: false,
            shrinkWrap: true,
            crossAxisCount: 2,
            children: _photos.map((desc) =>
              GridTile(
               child: ImageCard(
                 height: 100,
                 icon: Icons.add,
                 title: Text(desc,
                   style: _t.textTheme.button,
                   textAlign: TextAlign.center,
                 ),
                 onTap: () async {

                 },
               )
              )
            ).toList()
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              child: Text('CONTINUAR',
                style: _t.accentTextTheme.button
              ),
              color: _t.accentColor,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.inspectionStep3);
              },
            ),
          )
        ]
      )
    );
  }
}