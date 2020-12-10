import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/services/base.dart';
import 'package:legall_rimac_virtual/localizations.dart';
import 'package:legall_rimac_virtual/models/inspection_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:legall_rimac_virtual/routes.dart';
import 'package:intl/intl.dart';


class InspectionCompleteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InspectionCompleteScreenState();
}

class InspectionCompleteScreenState extends State<InspectionCompleteScreen> {
  Completer<GoogleMapController> _controller = Completer();
  final Geocoding _geocoding = Geocoder.local;
  String _addressDesc = null;

  @override
  Widget build(BuildContext context) {
    final InspectionModel model =  ModalRoute.of(context).settings.arguments;
    ThemeData _t = Theme.of(context);
    AppLocalizations _l = AppLocalizations.of(context);

    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(model.location.latitude, model.location.longitude),
      zoom: 1.4746,
    );

    _geocoding.findAddressesFromCoordinates(Coordinates(model.location.latitude, model.location.longitude))
    .then((address) {
      if (address.isNotEmpty) {
        setState(() {
          var firstAddress = address.first;
          _addressDesc = "${firstAddress.countryName}, ${firstAddress.addressLine}";
        });
      }
    });

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(_l.translate('inspection is complete'),
                            style: _t.textTheme.headline6
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(_addressDesc ?? _l.translate('locating'),
                          style: _t.textTheme.subtitle1,

                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text('${DateFormat('d MMM yyyy, hh:mm a').format(DateTime.now())}',
                            style: _t.textTheme.subtitle1
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(_l.translate('gps coors'),
                          style: _t.textTheme.subtitle2,
                        ),
                        Text('${model.location.latitude}, ${model.location.longitude}')
                      ],
                    )
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