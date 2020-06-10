import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:indigo24/services/user.dart' as user;

class Api {
  Response response;

  var unique = user.unique;
  var customerID = user.id;

  static BaseOptions options = new BaseOptions(
    baseUrl: "https://api.indigo24.xyz/api/v2.1",
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );

  Dio dio = new Dio(options);

  doTransfer(toID, amount) async {
    try {
      response = await dio.post("/check/send/money'", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "toID": "$toID",
        "amount": "$toID",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  getTransactions(page) async {
    try {
      response = await dio.post("/get/transactions", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "page": "$page",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  checkPhoneForSendMoney(phone) async {
    try {
      response = await dio.post("/check/send/money/phone", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "phone": "$phone",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  payService(serviceID, account, amount) async {
    try {
      response = await dio.post("/service/pay", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "serviceID": "$serviceID",
        "amount": "$amount",
        "account": "$account",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  getServices(categoryID) async {
    try {
      response = await dio.post("/get/services", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "categoryID": "$categoryID"
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  getHistories() async {
    try {
      response = await dio.post("/get/histories",
          data: {"customerID": "$customerID", "unique": "$unique"});
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  getCategories() async {
    try {
      response = await dio.post("/get/categories",
          data: {"customerID": "$customerID", "unique": "$unique"});
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  
  getCountries() async{
    try {
      response = await dio.post("/get/countries", data: {
        "_token": "8F@RgTHf7Ae1_M#Lv0!K4kmcNb6por52QU39",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.response.statusCode);
      }
    }
  }

  getExchangeRate() async {
    print("Getting exchanges for $customerID with $unique");
    try {
      response = await dio.post("/get/exchanges", data: {
        "_token": "#8kX1xtDr4qSY8_C9!N@cC9bvT0Pilk85DS32",
        "customerID": "$customerID",
        "unique": "$unique"
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  likeTape(String tapeId) async {
    try {
      response = await dio.post("/tape/like", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "tapeID": "$tapeId",
      });
      print("LIKE TAPE ${response.data}");

      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  getTapes(String page) async {
    try {
      response = await dio.post("/get/tapes", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "page": "$page",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
      } else {
      }
    }
  }

  getTape(tapeID) async {
    try {
      response = await dio.post("/get/tape", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "tapeID": "$tapeID",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }

  addCommentToTape(String comment, String tapeID) async {
    try {
      response = await dio.post("/get/tapes", data: {
        "customerID": "$customerID",
        "unique": "$unique",
        "comment": "$comment",
        "tapeID": "$tapeID",
      });
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(response.statusCode);
        print(e.response.statusCode);
      }
    }
  }
}
