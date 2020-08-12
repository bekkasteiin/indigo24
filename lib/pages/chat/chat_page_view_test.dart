import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/full_photo.dart';
import 'package:indigo24/widgets/player.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:flutter_downloader/flutter_downloader.dart';

class DeviderMessageWidget extends StatelessWidget {
  final date;
  const DeviderMessageWidget({Key key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Center(
          child: Text(
            '$date',
            style: TextStyle(fontSize: 16, color: darkGreyColor2),
          ),
        ),
      ),
    );
  }
}

File uploadingImage;

List imageCount = [];
var test;

class AudioMessage extends StatelessWidget {
  final url;
  AudioMessage(this.url);

  @override
  Widget build(BuildContext context) {
    print(url);
    print(url);
    print(url);
    print(url);
    print(url);
    print(url);
    print(url);
    print(url);
    return PlayerWidget(url: url);
  }
}

class ImageMessage extends StatelessWidget {
  final imageUrl;
  final fullImageUrl;
  final imageCount;
  ImageMessage(this.imageUrl, this.fullImageUrl, {this.imageCount});

  Widget placeholder(context) {
    return Container(
      child: uploadingImage != null
          ? Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  child: Image.file(uploadingImage, fit: BoxFit.cover),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  color: Colors.grey.withOpacity(0.5),
                ),
                Center(),
              ],
            )
          : Center(),
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: CachedNetworkImage(
            placeholder: (context, url) => placeholder(context),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'assets/preloader.gif',
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: imageUrl,
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            // width: 200.0,
            // height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullPhoto(url: fullImageUrl),
            ),
          );
        },
        padding: EdgeInsets.all(0),
      ),
    );
  }
}

class VideoMessage extends StatefulWidget {
  final url;
  VideoMessage(this.url);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.url);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                ClosedCaption(text: _controller.value.caption.text),
                _PlayPauseOverlay(controller: _controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
              ],
            ),
          )
        : Container();
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

class FileMessage extends StatefulWidget {
  FileMessage({Key key, this.url}) : super(key: key);

  final String url;

  @override
  _FileMessageState createState() => _FileMessageState();
}

class _FileMessageState extends State<FileMessage> {
  var percent = '';

  List<_TaskInfo> tasks;
  _TaskInfo globalTask;
  List<_ItemHolder> items;
  bool isLoading;
  bool permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    isLoading = true;
    permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        child: InkWell(
          onTap: globalTask.status == DownloadTaskStatus.complete
              ? () {
                  _openDownloadedFile(globalTask).then((success) {
                    if (!success) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Cannot open this file')));
                    }
                  });
                }
              : null,
          child: _buildActionForTask(globalTask),
        ),
      ),
    );
  }

  _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (true) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = globalTask?.taskId == id;
      if (task != null) {
        setState(() {
          globalTask.status = status;
          globalTask.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (true) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  var downloadTaskId;

  download(String url, String savePath) async {
    print("download start");
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savePath,
      showNotification:
          false, // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
    final tasks = await FlutterDownloader.loadTasks();
    setState(() {
      downloadTaskId = taskId;
    });
    print("download end");
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
        ),
      );

      print(response.headers);

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => PDFViewer(raf.path)),
      // );
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
      setState(() {
        percent = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Widget _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RaisedButton.icon(
        onPressed: () async {
          var tempDir = await getTemporaryDirectory();
          String fullPath = tempDir.path + "/boo2.pdf'";
          print('full path $fullPath');
          _requestDownload(task);
        },
        icon: Icon(
          Icons.file_download,
          color: whiteColor,
        ),
        color: Colors.green,
        textColor: whiteColor,
        label: Text('Download $percent'),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        child: new Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Ready',
            style: TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              _delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Failed', style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: false,
        openFileFromNotification: false);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      if (!await Permission.storage.isGranted) {
        PermissionStatus status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          return false;
        }
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    setState(() {
      globalTask = _TaskInfo(name: widget.url, link: widget.url);
    });

    tasks?.forEach((task) {
      print("task is ${globalTask.link} ${task.url}");
      if (globalTask.link == task.url) {
        globalTask.taskId = task.taskId;
        globalTask.status = task.status;
        globalTask.progress = task.progress;
      }
    });

    permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class PDFViewer extends StatefulWidget {
  final file;
  PDFViewer(this.file);

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int _actualPageNumber = 1, _allPagesCount = 0;
  PdfController _pdfController;

  @override
  void initState() {
    _pdfController =
        PdfController(document: PdfDocument.openAsset(widget.file));
    super.initState();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(primaryColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage(
                    'assets/images/back.png',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('${localization.file}'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: () {
                  _pdfController.previousPage(
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 100),
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '$_actualPageNumber/$_allPagesCount',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                icon: Icon(Icons.navigate_next),
                onPressed: () {
                  _pdfController.nextPage(
                    curve: Curves.ease,
                    duration: Duration(milliseconds: 100),
                  );
                },
              ),
            ],
          ),
          body: PdfView(
            documentLoader: Center(child: CircularProgressIndicator()),
            pageLoader: Center(child: CircularProgressIndicator()),
            controller: _pdfController,
            onDocumentLoaded: (document) {
              setState(() {
                _allPagesCount = document.pagesCount;
              });
            },
            onPageChanged: (page) {
              setState(() {
                _actualPageNumber = page;
              });
            },
          ),
        ),
      );
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
