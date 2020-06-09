import 'dart:convert';

import 'package:dio/dio.dart';

class Api {
  Response response;

  var unic = "bfe9101ba2cf530a650c9985989437055cc91709";
  var customerID = "66944";

  static BaseOptions options = new BaseOptions(
    baseUrl: "https://api.indigo24.xyz/api/v2.1",
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );

  Dio dio = new Dio(options);

  getExchangeRate() async {
    try {
      response = await dio.post("/get/exchanges", data: {
        "_token": "#8kX1xtDr4qSY8_C9!N@cC9bvT0Pilk85DS32",
        "customerID": "$customerID",
        "unique": "$unic"
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
        "unique": "$unic",
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
        "unique": "$unic",
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
        "unique": "$unic",
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
        "unique": "$unic",
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
