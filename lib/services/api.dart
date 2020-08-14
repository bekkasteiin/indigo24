import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/progress_bar.dart';

import 'helper.dart';

class Api {
  static BaseOptions _options = new BaseOptions(
    baseUrl: '$baseUrl',
    connectTimeout: 15000,
    receiveTimeout: 3000,
  );

  Dio _dio = new Dio(_options);
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
      print('post result $response');
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
        return e.response.data;
      } else {
        print('error while getting value');
        print(e.request.baseUrl);
        print(e.request.data);
        print(e.request.method);
      }
    }
  }

  _getRequest(String path, queryParameters) async {
    Response response;
    print('this is get request');
    try {
      response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
        return e.response.data;
      } else {
        print(e.request.baseUrl);
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
    return _postRequest('/registration', data);
  }

  getConfig() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      '_token': '$_configToken',
    };
    var result = await _postRequest('/get/config', data);
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
    var result = await _postRequest('/token/fcm/update', data);
    if (result['success'] == true) {
      print('Token updated to $token $result');
      return true;
    } else {
      print('Else token updated to $token $result');
      return result;
    }
  }

  checkRegistration(phone) async {
    dynamic data = {
      'phone': '$phone',
      '_token': '$_checkPhoneToken',
    };
    return _postRequest('/check/registration', data);
  }

  getHistoryBalance(page) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
    };
    return _postRequest('/get/balance/history', data);
  }

  logOutHttp() async {
    dynamic data = {
      'customerID': '${user.id}',
      '_token': '$_logoutToken',
    };
    return _postRequest('/logout/fix', data);
  }

  sendSms(phone) async {
    dynamic data = {
      'phone': '$phone',
      '_token': '$_sendSmsToken',
    };
    return _postRequest('/sms/send', data);
  }

  restorePassword(phone) async {
    dynamic data = {
      'phone': '$phone',
    };
    return _postRequest('/restore', data);
  }

  getService(serviceID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'serviceID': '$serviceID'
    };
    return _postRequest('/get/payments', data);
  }

  checkSms(phone, code) async {
    dynamic data = {
      'phone': '$phone',
      'code': '$code',
    };
    return _postRequest('/check/sms', data);
  }

  createPin(pinCode) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'pinCode': '$pinCode'
    };

    var result = await _postRequest('/create/pin', data);
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
    var result = await _postRequest('/get/balance', data);
    if (result['success'] == true) {
      SharedPreferencesHelper.setString(
          'balance', '${result['result']['balance']}');
      SharedPreferencesHelper.setString(
          'balanceInBlock', '${result['result']['balanceInBlock']}');
      user.balance = '${result['result']['balance']}';
      user.balanceInBlock = '${result['result']['balanceInBlock']}';

      print('Balance in block ${user.balanceInBlock}');
    }
    return result;
  }

  signIn(phone, password) async {
    dynamic data = {
      'phone': '$phone',
      'password': '$password',
    };

    var result = await _postRequest('/check/authentication', data);
    if (result['success'] == true) {
      SharedPreferencesHelper.setString('customerID', '${result['ID']}');
      SharedPreferencesHelper.setString('phone', '+$phone');
      SharedPreferencesHelper.setString('name', '${result['name']}');
      SharedPreferencesHelper.setString('email', '${result['email']}');
      SharedPreferencesHelper.setString('avatar', '${result['avatar']}');
      SharedPreferencesHelper.setString('unique', '${result['unique']}');
      SharedPreferencesHelper.setString('pin', '${result['pin']}');
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
    return _postRequest('/check/token', data);
  }

  withdraw(amount) async {
    dynamic data = {
      '_token': '$_token',
      'amount': '$amount',
      'customerID': '${user.id}',
      'unique': '${user.unique}'
    };
    return _postRequest('/pay/out', data);
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
      return _dio.post('/check/send/money', data: data);
    } else {
      return _dio.post('/check/send/money', data: {
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
    return _postRequest('/get/transactions', data);
  }

  checkPhoneForSendMoney(phone) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'phone': '$phone',
    };
    return _postRequest('/check/send/money/phone', data);
  }

  calculateSum(serviceID, account, amount) async {
    dynamic queryParameters = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'serviceID': '$serviceID',
      'amount': '$amount',
      'account': '$account',
    };
    return _getRequest('/hermes/sum/calculate', queryParameters);
  }

  payService(serviceID, account, amount) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'serviceID': '$serviceID',
      'amount': '$amount',
      'account': '$account',
    };
    return _postRequest('/service/pay', data);
  }

  getServices(categoryID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'categoryID': '$categoryID'
    };
    return _postRequest('/get/services', data);
  }

  getHistories(page, {String fromDate, String toDate}) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page'
    };

    if (fromDate != null && toDate != null) {
      data = {
        'customerID': '${user.id}',
        'unique': '${user.unique}',
        'page': '$page',
        'fromDate': fromDate,
        'toDate': toDate,
      };
    }
    return _postRequest('/get/histories', data);
  }

  refill(amount) async {
    dynamic data = {
      '_token': '$_tokenwhat',
      'amount': '$amount',
      'customerID': '${user.id}',
      'unique': '${user.unique}'
    };

    return _postRequest('/pay/in', data);
  }

  getCategories() async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
    };

    return _postRequest('/get/categories', data);
  }

  getCountries() async {
    dynamic data = {
      '_token': '$_countryToken',
    };
    return _postRequest('/get/countries', data);
  }

  getExchangeRate() async {
    dynamic data = {
      '_token': '$exchangeToken',
      'customerID': '${user.id}',
      'unique': '${user.unique}'
    };
    return _postRequest('/get/exchanges', data);
  }

  likeTape(String tapeId) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'tapeID': '$tapeId',
    };
    return _postRequest('/tape/like', data);
  }

  getTapes(String page) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'page': '$page',
    };
    return _postRequest('/get/tapes', data);
  }

  getTape(tapeID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'tapeID': '$tapeID',
    };
    return _postRequest('/get/tape', data);
  }

  //TODO fix it
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

      print(
          'Adding tape with data ${formData.files[0].value.length}\n    FIEDLS ${formData.fields}');

      _sendingMsgProgressBar.show(context, '$p');

      Response response = await _dio.post(
        '/tape/add',
        data: formData,
        onSendProgress: (int sent, int total) {
          String percent = (sent / total * 100).toStringAsFixed(2);
          print('$percent% $total');
        },
      );

      print('Getting response from TAPE upload ${response.data}');
      _sendingMsgProgressBar.hide();
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
        print(e.request);
        print(e.message);
      }
      print('Error when upload TAPE: ${e.response.data}');
      _sendingMsgProgressBar.hide();
      return e.response.data;
    }
  }

  uploadAvatar(_path) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'file': await MultipartFile.fromFile(_path),
    };
    return _postRequest('/avatar/upload', data);
  }

  uploadMedia(_path, type) async {
    dynamic data = {
      'user_id': '${user.id}',
      'userToken': '${user.unique}',
      'file': await MultipartFile.fromFile(_path),
      'type': type
    };
    var result = await _postRequest('$mediaChat', data);
    print(result);
    return result;
  }

  addCommentToTape(String comment, String tapeID) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'comment': '$comment',
      'tapeID': '$tapeID',
    };
    return _postRequest('/tape/comment/add', data);
  }

  blockUser(String userId) async {
    dynamic data = {
      'customerID': '${user.id}',
      'unique': '${user.unique}',
      'blockedID': '$userId',
    };
    return _postRequest('/block/user', data);
  }
}
