import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _sharedPreferences;
  SettingsRepository(this._sharedPreferences);

  String getInspectionId() {
    return _sharedPreferences.getString('inspectionId');
  }

  void setInspectionId(String inspectionId) {
    _sharedPreferences.setString('inspectionId', inspectionId);
  }
}