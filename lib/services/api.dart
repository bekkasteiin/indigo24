import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/progress_bar.dart';

import 'helper.dart';

class Api {
  static BaseOptions _options = BaseOptions(
    baseUrl: '$baseUrl',
    connectTimeout: 60000,
    receiveTimeout: 3000,
  );

  jsonConcat(o1, o2) {
    for (var key in o2) {
      o1[key] = o2[key];
    }
    return o1;
  }

  Dio _dio = Dio(_options);
  static const _sendSmsToken = '2MSldk_7!FUh3zB18XoEfIe#nY69@0tcP5Q4';
  static const _registrationToken = 'BGkA2as4#h_J@5txId3fEq6e!F80UMj197ZC';
  static const _checkPhoneToken = 'EG#201wR8Wk6ZbvMFf_e@39h7V!tI5gBTx4a';
  static const _configToken = 'D@Xo8b56r#7e1iZElhH39xK!WkB_42vYAG0p';
  static const _logoutToken = '0#!_kA8B@ncV2';
  static const _token = '1E#cw!5yofLCB3b_DX07x@4uKT6FH9mta8J2';
  String _tokenwhat = 'UGfbx#Du61zSNiXgjm4E!@M2OFJ98t3075_e';
  String _countryToken = '8F@RgTHf7Ae1_M#Lv0!K4kmcNb6por52QU39';
  String exchangeToken = '#8kX1xtDr4qSY8_C9!N@cC9bvT0Pilk85DS32';
  ProgressBar _sendingMsgProgressBar;

  var device = 'deviceName';
  // @TODO change device NAME;

  _postRequest(String path, data) async {
    Response response;
    try {
      response = await _dio.post(path, data: data);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.request.path);
        print(e.response.request.data);
        print(e.response.statusCode);
        return e.response.data;
      } else {
        print('error while getting value');
        print('error named $e');
        print(e.request.uri);
        print(e.request.headers);
        print(e.request.data);
        print(e.request.method);
      }
    }
  }

  _getRequest(String path, queryParameters) async {
    Response response;
    try {
      response = await _dio.get(path, queryParameters: queryParameters);
      print('this is get request $response');
      return json.decode(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.request.path);
        print(e.response.request.data);
        print(e.response.statusCode);
        return e.response.data;
      } else {
        print(e.request.uri.toString());
        print(e.request.data);
        print(e.request.method);
      }
    }
  }

  register(phone, name, password, email) async {
    dynamic data = {
      'name': '$name',
      'password': '$password',
      'email': '$email',
      'phone': '$phone',
      '_token': '$_registrationToken',
      'device': '$device',
    };
    return _postRequest('api/v2.1/registration', data);
  }

  getConfig() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      '_token': '$_configToken',
    };
    var result = await _postRequest('api/v2.1/get/config', data);
    var commission = result['commissions'];
    var withdrawConfig = commission['withdraw'];
    var refillConfig = commission['refill'];

    withdrawCommission = '${withdrawConfig['commission']}';
    withdrawMinCommission = '${withdrawConfig['minCommission']}';
    withdrawMin = '${withdrawConfig['min']}';
    withdrawMax = '${withdrawConfig['max']}';

    refillCommission = '${refillConfig['commission']}';
    refillMinCommission = '${refillConfig['minCommission']}';
    refillMin = '${refillConfig['min']}';
    refillMax = '${refillConfig['max']}';

    return result;
  }

  updateFCM(token) async {
    dynamic data = {
      'customerID': '${user.id}',
      'token': '$token',
      'unique': '${user.unique}'
    };
    var result = await _postRequest('api/v2.1/token/fcm/update', data);
    if (result['success'] == true) {
      return true;
    } else {
      return result;
    }
  }

  checkRegistration(phone) async {
    dynamic data = {
      'phone': '$phone',
      '_token': '$_checkPhoneToken',
    };
    return _postRequest('api/v2.1/check/registration', data);
  }

  settingsSave({String name, String city}) async {
    dynamic data;
    if (name != null) {
      data = {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'name': name,
      };
    }

    if (city != null) {
      data = {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'city': city,
      };
    }
    return _postRequest('api/v2.1/settings/save', data);
  }

  getProfile() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
    };
    return _postRequest('api/v2.1/get/profile', data);
  }

  // getNews() async {
  // }

  getHistoryBalance(page) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
    };
    return _postRequest('api/v2.1/get/balance/history', data);
  }

  getFilteredHistoryBalance(page, String fromDate, String toDate) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
      'fromDate': fromDate,
      'toDate': toDate,
    };
    return _postRequest('api/v2.2/get/balance/history', data);
  }

  logOutHttp() async {
    dynamic data = {
      'customerID': '${user.id}',
      '_token': '$_logoutToken',
    };
    return _postRequest('api/v2.1/logout/fix', data);
  }

  sendSms(phone) async {
    dynamic data = {
      'phone': '$phone',
      '_token': '$_sendSmsToken',
    };
    return _postRequest('api/v2.1/sms/send', data);
  }

  restorePassword(phone) async {
    dynamic data = {
      'phone': '$phone',
    };
    return _postRequest('api/v2.1/restore', data);
  }

  getService(serviceID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'serviceID': '$serviceID'
    };
    return _postRequest('api/v2.1/get/payments', data);
  }

  checkSms(phone, code) async {
    dynamic data = {
      'phone': '$phone',
      'code': '$code',
    };
    return _postRequest('api/v2.1/check/sms', data);
  }

  createPin(pinCode) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'pinCode': '$pinCode'
    };

    var result = await _postRequest('api/v2.1/create/pin', data);
    if (result['success'] == true) {
      SharedPreferencesHelper.setString('pin', '$pinCode');
      user.pin = '$pinCode';
    }
    return result;
  }

  getBalance() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
    };
    var result = await _postRequest('api/v2.1/get/balance', data);
    if (result['success'] == true) {
      SharedPreferencesHelper.setString(
          'balance', '${result['result']['balance']}');
      SharedPreferencesHelper.setString(
          'balanceInBlock', '${result['result']['balanceInBlock']}');
      user.balance = '${result['result']['balance']}';
      user.balanceInBlock = '${result['result']['balanceInBlock']}';
    }
    return result;
  }

  signIn(phone, password) async {
    dynamic data = {
      'phone': '$phone',
      'password': '$password',
    };

    var result = await _postRequest('api/v2.1/check/authentication', data);

    if (result['success'] == true) {
      SharedPreferencesHelper.setString('customerID', '${result['ID']}');
      SharedPreferencesHelper.setString('phone', '+$phone');
      SharedPreferencesHelper.setString('name', '${result['name']}');
      SharedPreferencesHelper.setString('email', '${result['email']}');
      SharedPreferencesHelper.setString('avatar', '${result['avatar']}');
      SharedPreferencesHelper.setString('unique', '${result['unique']}');
      SharedPreferencesHelper.setString('pin', '${result['pin']}');
      user.identified = result['identified'];
      user.id = '${result['ID']}';
      user.phone = '+$phone}';
      user.name = '${result['name']}';
      user.email = '${result['email']}';
      user.avatar = '${result['avatar']}';
      user.unique = '${result['unique']}';
      user.pin = '${result['pin']}';
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
      String token = await _firebaseMessaging.getToken();
      await updateFCM(token);
    }
    return result;
  }

  checkUnique(newUnique, newCustomerID) async {
    dynamic data = {
      'customerID': '$newCustomerID',
      'unique': '$newUnique',
    };
    return _postRequest('api/v2.1/check/token', data);
  }

  withdraw(String path, amount) async {
    dynamic data = {
      '_token': '$_token',
      'amount': '$amount',
      'customerID': '${user.id}',
      'unique': '${user.unique}'
    };
    return _postRequest(path, data);
  }

  doTransfer(toID, amount, {transferChat, String comment}) async {
    dynamic data;
    if (transferChat == null) {
      if (comment != null) {
        data = {
          'customerID': '${user.id}',
          'unique': '${user.unique}',
          'toID': '$toID',
          'amount': '$amount',
          'comment': comment,
        };
      } else {
        data = {
          'customerID': '${user.id}',
          'unique': '${user.unique}',
          'toID': '$toID',
          'amount': '$amount',
        };
      }
      return _postRequest('api/v2.1/check/send/money', data);
    } else {
      return _postRequest('api/v2.1/check/send/money', {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'toID': '$toID',
        'amount': '$amount',
        'chatTransfer': '1',
      });
    }
  }

  getTransactions(page, {String fromDate, String toDate}) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
    };
    if (fromDate != null && toDate != null) {
      data = {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'fromDate': fromDate,
        'toDate': toDate,
        'page': '$page',
      };
    }
    return _postRequest('api/v2.1/get/transactions', data);
  }

  getFilteredTransactions(page, String fromDate, String toDate) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'fromDate': fromDate,
      'toDate': toDate,
      'page': '$page',
    };

    return _postRequest('api/v2.2/get/transactions', data);
  }

  checkPhoneForSendMoney(phone) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'phone': '$phone',
    };
    return _postRequest('api/v2.1/check/send/money/phone', data);
  }

  calculateSum(serviceID, account, amount, int providerId) async {
    switch (providerId) {
      case 6:
        dynamic queryParameters = {
          'customerID': '${user.id}',
          'unique': '${user.unique}',
          'serviceID': '$serviceID',
          'amount': '$amount',
          'account': '$account',
        };
        return _getRequest('api/v2.1/hermes/sum/calculate', queryParameters);
        break;
      case 1:
        dynamic queryParameters = {
          'customerID': '${user.id}',
          'unique': '${user.unique}',
          'serviceID': '$serviceID',
          'amount': '$amount',
          'account': '$account',
        };
        return _postRequest('api/v2/ultra-pay/conversion', queryParameters);
        break;
      default:
        dynamic queryParameters = {
          'customerID': '${user.id}',
          'unique': '${user.unique}',
          'serviceID': '$serviceID',
          'amount': '$amount',
          'account': '$account',
        };
        return _getRequest('api/v2.1/hermes/sum/calculate', queryParameters);
        break;
    }
  }

  payService(serviceID, controllers) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'serviceID': '$serviceID',
    };
    controllers.forEach((element) {
      var t = {
        if (element['name'] == 'account' || element['name'] == 'amount')
          '${element['name']}':
              '${element['controller'].text.toString().replaceAll(" ", '')}'
        else
          '${element['name']}': '${element['controller'].text}'
      };
      data.addAll(t);
    });
    print(data);
    return _postRequest('api/v2.1/service/pay', data);
  }

  searchServices(String query) {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'search': query,
    };
    return _postRequest('api/v2.1/service/search', data);
  }

  getServices(categoryID, {locationId, locationType}) async {
    dynamic data;
    if (locationId != null && locationType != null) {
      data = {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'categoryID': '$categoryID',
        'location_type': locationType,
        'location_id': locationId
      };
    } else {
      data = {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'categoryID': '$categoryID'
      };
    }
    return _postRequest('api/v2.1/get/services', data);
  }

  getWithdraws() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
    };
    return _postRequest('api/v2.1/withdraw/providers', data);
  }

  getHistories(page) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page'
    };

    return _postRequest('api/v2.1/get/histories', data);
  }

  getFilteredHistories(page, String fromDate, String toDate) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
      'fromDate': fromDate,
      'toDate': toDate,
    };

    return _postRequest('api/v2.2/get/histories', data);
  }

  refill(amount) async {
    dynamic data = {
      '_token': '$_tokenwhat',
      'amount': '$amount',
      'customerID': '${user.id}',
      'unique': '${user.unique}'
    };

    return _postRequest('api/v2.1/pay/in', data);
  }

  getCategories() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
    };

    return _postRequest('api/v2.1/get/categories', data);
  }

  getCategory(int categoryId, String locationType) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'categoryID': categoryId,
      'location_type': locationType,
    };

    return _postRequest('api/v2.1/get/category/locations', data);
  }

  getCountries() async {
    dynamic data = {
      '_token': '$_countryToken',
    };
    return _postRequest('api/v2.1/get/countries', data);
  }

  getExchangeRate() async {
    dynamic data = {
      '_token': '$exchangeToken',
      'customerID': '${user.id}',
      'unique': '${user.unique}'
    };
    return _postRequest('api/v2.1/get/exchanges', data);
  }

  likeTape(String tapeId) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'tapeID': '$tapeId',
    };
    return _postRequest('api/v2.1/tape/like', data);
  }

  getTapes(String page) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
    };
    return _postRequest('api/v2.1/get/tapes', data);
  }

  getTape(tapeID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'tapeID': '$tapeID',
    };
    return _postRequest('api/v2.1/get/tape', data);
  }

  addTape(_path, title, description, context) async {
    _sendingMsgProgressBar = ProgressBar();
    var p;

    try {
      FormData formData = FormData.fromMap({
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'file': await MultipartFile.fromFile(_path),
        'title': '$title',
        'description': '$description'
      });

      _sendingMsgProgressBar.show(context, '$p');

      Response response = await _dio.post(
        'api/v2.1/tape/add',
        data: formData,
        onSendProgress: (int sent, int total) {},
      );

      _sendingMsgProgressBar.hide();
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.statusCode);
      } else {
        print(e.request);
        print(e.message);
      }
      _sendingMsgProgressBar.hide();
      return e.response.data;
    }
  }

  uploadAvatar(_path) async {
    FormData data = FormData.fromMap({
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'file': await MultipartFile.fromFile(_path),
    });
    return _postRequest('api/v2.1/avatar/upload', data);
  }

  uploadMedia(_path, type) async {
    FormData data = FormData.fromMap({
      'user_id': '${user.id}',
      'userToken': '${user.unique}',
      'file': await MultipartFile.fromFile(_path),
      'type': type
    });
    return _postRequest('$mediaChat', data);
  }

  addCommentToTape(String comment, String tapeID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'comment': '$comment',
      'tapeID': '$tapeID',
    };
    return _postRequest('api/v2.1/tape/comment/add', data);
  }

  blockUser(String userId) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'blockedID': '$userId',
    };
    return _postRequest('api/v2.1/block/user', data);
  }
}
