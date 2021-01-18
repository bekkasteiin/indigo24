import 'package:indigo24/services/shared_preference/shared_strings.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  setUser() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    user.id = sp.getString(SharedStrings.customerID);
    user.phone = sp.getString(SharedStrings.phone);
    user.balance = sp.getString(SharedStrings.balance);
    user.balanceInBlock = sp.getString(SharedStrings.balanceInBlock);
    user.name = sp.getString(SharedStrings.name);
    user.email = sp.getString(SharedStrings.email);
    user.avatar = sp.getString(SharedStrings.avatar);
    user.unique = sp.getString(SharedStrings.unique);
    user.pin = sp.getString(SharedStrings.pin);
    user.sound = sp.getString(SharedStrings.sound);

    return user.id;
  }
}
