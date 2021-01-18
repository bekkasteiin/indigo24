import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}
