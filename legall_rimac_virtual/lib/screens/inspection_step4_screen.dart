import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';

class InspectionStep4Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep4ScreenState();
}

class InspectionStep4ScreenState extends State<InspectionStep4Screen> {
  ThemeData _t;

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    _t = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Inspección Virtual - Paso 4'),
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
              Text('Favor ingresar información adicional de su vehículo. e.g. accesorios.'),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(5),
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1
                  )
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      border: InputBorder.none
                  ),
                  controller: _textController,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  child: Text('FINALIZAR INSPECIÓN',
                      style: _t.accentTextTheme.button
                  ),
                  color: _t.accentColor,
                  onPressed: () {

                  },
                ),
              )
            ]
        )
    );
  }
}