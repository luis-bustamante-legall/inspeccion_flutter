import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:legall_rimac_virtual/widgets/image_card.dart';

class InspectionStep3Screen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => InspectionStep3ScreenState();
}

class InspectionStep3ScreenState extends State<InspectionStep3Screen> {
  ThemeData _t;
  final _photos = [
    'Tanque de gas',
  ];

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    _t = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Inspección Virtual - Paso 3'),
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
              Text('Agregue fotos adicionales si así lo desea:'),
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
                              )
                          )
                      )
                  ).toList()..add(
                    GridTile(
                      child: Card(
                        child:  InkWell(
                            onTap: () async {
                              final textController = TextEditingController();
                              var text = await showDialog<String>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Descripción de la foto'),
                                  content: TextField(
                                    controller: textController,
                                    decoration: InputDecoration(
                                      hintText: 'Descripción'
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('CANCELAR'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('GUARDAR'),
                                      onPressed: () {
                                        Navigator.pop(context,textController.text);
                                      },
                                    )
                                  ],
                                )
                              );
                              if ((text??'').isNotEmpty) {
                                setState(() {
                                  _photos.add(text);
                                });
                              }
                            },
                            child:Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                      color: Colors.indigo,
                                    ),
                                    Text('Agregar Foto Nueva',
                                      style: TextStyle(
                                          color: Colors.indigo
                                      ),
                                    )
                                  ],
                                ),
                              )
                            )
                        )
                      ),
                    )
                  )
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  child: Text('CONTINUAR',
                      style: _t.accentTextTheme.button
                  ),
                  color: _t.accentColor,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.inspectionStep4);
                  },
                ),
              )
            ]
        )
    );
  }
}