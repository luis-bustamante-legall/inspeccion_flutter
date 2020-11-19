import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:legall_rimac_virtual/routes.dart';


class InspectionCompleteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InspectionCompleteScreenState();
}

class InspectionCompleteScreenState extends State<InspectionCompleteScreen> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.0904977, 77.0473731),
    zoom: 1.4746,
  );

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(_l.translate('inspection completed'))
        ),
        body: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15,right: 15),
                    child: Icon(Icons.check_circle_outline,
                      size: 50,
                      color: Colors.green,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_l.translate('inspection is complete'),
                          style: _t.textTheme.headline6
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text('Lima, JR Moquegua 718 Dpto 603',
                        style: _t.textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('2 Ago 2020, 4:45 PM',
                          style: _t.textTheme.subtitle1
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(_l.translate('gps coors'),
                        style: _t.textTheme.subtitle2,
                      ),
                      Text('12.0904977, 77.0473731')
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: SizedBox(
                  height: 400,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                )
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  child: Text(_l.translate('close').toUpperCase(),
                      style: _t.accentTextTheme.button
                  ),
                  color: _t.accentColor,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context,AppRoutes.home,
                    (Route<dynamic> route) => false);
                  },
                ),
              )
            ]
        )
    );
  }
}