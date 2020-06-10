import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('$key').toString() ?? 0;
  }

  static Future<String> getBalance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('balance').toString() ?? 0;
  }

  static Future<String> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name').toString() ?? 0;
  }

  static Future<String> getBalanceInBlock() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('balanceInBlock').toString() ?? 0;
  }

  static Future<String> getCustomerID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('customerID').toString() ?? 0;
  }

  static Future<String> getUnique() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('unique').toString() ?? 0;
  }
}