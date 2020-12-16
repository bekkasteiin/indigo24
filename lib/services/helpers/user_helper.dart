import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/user.dart' as user;

class UserHelper {
  setUser() async {
    user.id = await SharedPreferencesHelper.getCustomerID();
    user.phone = await SharedPreferencesHelper.getString('phone');
    user.balance = await SharedPreferencesHelper.getString('balance');
    user.balanceInBlock =
        await SharedPreferencesHelper.getString('balanceInBlock');
    user.name = await SharedPreferencesHelper.getString('name');
    user.email = await SharedPreferencesHelper.getString('email');
    user.avatar = await SharedPreferencesHelper.getString('avatar');
    user.unique = await SharedPreferencesHelper.getString('unique');
    user.pin = await SharedPreferencesHelper.getString('pin');
    user.sound = await SharedPreferencesHelper.getString('sound');
    return user.id;
  }
}
