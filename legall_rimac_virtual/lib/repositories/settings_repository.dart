import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _sharedPreferences;
  SettingsRepository(this._sharedPreferences);

  String getInspectionId() {
    return _sharedPreferences.getString('inspectionId');
  }
  String getInspectionIdAll() {
    return _sharedPreferences.getString('inspectionIdAll');
  }

  void setInspectionId(String inspectionId) {
    _sharedPreferences.setString('inspectionId', inspectionId);
  }

  void setInspectionIdAll(String inspectionId) {
    String allInspeccion = _sharedPreferences.getString('inspectionIdAll') ?? "";
    if(!allInspeccion.contains(inspectionId)){
      _sharedPreferences.setString('inspectionIdAll', "$allInspeccion$inspectionId");
    }
  }

}