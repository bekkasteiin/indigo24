import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:indigo24/services/api/http/api.dart';

class DownloadManager {
  DownloadManager(this._api);
  final Api _api;
  Future<bool> fileNetwork({
    @required String url,
    @required Function onReceiveProgress,
    @required String type,
  }) async {
    Response<ResponseBody> response = await _api.downloadFileNetworkawait(
      type: type,
      url: url,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );
    return response.statusCode == 200 ? true : false;
  }
}
