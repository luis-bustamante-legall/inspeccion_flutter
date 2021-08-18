import 'dart:async';

import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
abstract class BaseLocation {
  void newCoordinates(Coordinates coordinates);

  void gpsDisabled();

  void permissionDontAccept();

  void initConsultaLocalizacion();

  void validateRequestPermission({bool onlyFirst = true}) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permissionDontAccept();
      } else {
        _validateEnabledLocation(onlyFirst);
      }
    } else {
      _validateEnabledLocation(onlyFirst);
    }
  }

  void _validateEnabledLocation(bool onlyFirst) async {
    bool _serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!_serviceEnabled) {
      Geolocator.openLocationSettings();
    } else {
      getLocationUpdate(onlyFirst);
    }
  }

  void getLocationUpdate(bool onlyFirst) async {
      initConsultaLocalizacion();
          Geolocator.getCurrentPosition(forceAndroidLocationManager: true)
          .then((Position position) {
            _callbackLocation(position.latitude, position.longitude);
          });
  }

  void _callbackLocation(double latitude, double longitude) async {
    final coordinates = new Coordinates(latitude, longitude);
    newCoordinates(coordinates);
  }

  void disposeLocation() {
    //locationSubscription?.cancel();
  }

}
