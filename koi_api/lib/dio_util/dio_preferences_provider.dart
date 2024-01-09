import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider {
  factory PreferencesProvider() {
    _instance ??= PreferencesProvider._();
    return _instance!;
  }
  PreferencesProvider._() {
    _initPreferences();
  }
  static PreferencesProvider? _instance;
  late SharedPreferences? _preferences;
  Future<void> _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> setAccess(String value) async {
    await _initPreferences();
    await _preferences!.setString('access_token', value);
  }

  Future<String?> getAccess() async {
    await _initPreferences();
    return _preferences!.getString('access_token');
  }

  Future<void> clearAccess() async {
    await _initPreferences();
    await _preferences!.remove('access_token');
  }

  Future<void> setRefresh(String value) async {
    await _initPreferences();
    await _preferences!.setString('refresh_token', value);
  }

  Future<String?> getRefresh() async {
    await _initPreferences();
    return _preferences!.getString('refresh_token');
  }
}
