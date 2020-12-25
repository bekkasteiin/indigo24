import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/widgets/document/file_manager.dart';

class DownloadManager {
  DownloadManager(this._api);
  final Api _api;
  Future<bool> fileNetwork({
    @required String url,
    @required Function onReceiveProgress,
    @required String type,
  }) async {
    dynamic response = await _api.downloadFileNetworkawait(
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
    FileManager fileManager = FileManager();
    bool stored = await fileManager.storeFile(response);
    return stored;
  }
}
