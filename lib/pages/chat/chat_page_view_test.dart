import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/widgets/full_photo.dart';
import 'package:indigo24/widgets/player.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

var parser = EmojiParser();

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
            )),
        child: Center(
            child: Text(
          '$date',
          style: TextStyle(fontSize: 16, color: Color(0xFF5E5E5E)),
        )),
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
    return Container(
      child: PlayerWidget(url: url),
    );
  }
}

class ImageMessage extends StatelessWidget {
  final imageUrl;
  final fullImageUrl;
  final imageCount;
  ImageMessage(this.imageUrl, this.fullImageUrl, {this.imageCount});

  Widget placeholder(context){
    return Container(
      child: uploadingImage!=null?
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.7,
                  height: MediaQuery.of(context).size.width*0.7,
                  child: Image.file(uploadingImage, fit: BoxFit.cover),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.7,
                  height: MediaQuery.of(context).size.width*0.7,
                  color: Colors.grey.withOpacity(0.5),
                ),
                Center(
                  child: Image.asset("assets/preloader.gif", width: MediaQuery.of(context).size.width*0.3),
                ),
              ],
            ) : Center(
          child: Image.asset("assets/preloader.gif", width: MediaQuery.of(context).size.width*0.3),
        ),
      width: MediaQuery.of(context).size.width*0.7,
      height: MediaQuery.of(context).size.width*0.7,
      // padding: EdgeInsets.all(70.0),
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
            // progressIndicatorBuilder: (context, url, progress) {
            //   if(progress.progress == 1){
            //     uploadingImage = null;
            //   }
            //   return placeholder(context);
            // },
            placeholder: (context, url) => placeholder(context),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'assets/preloader.gif',
                width: MediaQuery.of(context).size.width*0.7,
                height: MediaQuery.of(context).size.width*0.7,
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: imageUrl,
            width: MediaQuery.of(context).size.width*0.7,
            height: MediaQuery.of(context).size.width*0.7,
            // width: 200.0,
            // height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FullPhoto(url: fullImageUrl)));
        },
        padding: EdgeInsets.all(0),
      ),
      // margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
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
    _controller = VideoPlayerController.network(
      widget.url
    );

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


var dio = Dio();

class FileMessage extends StatefulWidget {
  FileMessage({Key key, this.url}) : super(key: key);

  final String url;

  @override
  _FileMessageState createState() => _FileMessageState();
}

class _FileMessageState extends State<FileMessage> {
  var percent = '';


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
            }),
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

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      onPressed: () async {
        var tempDir = await getTemporaryDirectory();
        String fullPath = tempDir.path + "/boo2.pdf'";
        print('full path ${fullPath}');
        
        download2(dio, widget.url, fullPath);
      },
      icon: Icon(
        Icons.file_download,
        color: Colors.white,
      ),
      color: Colors.green,
      textColor: Colors.white,
      label: Text('Dowload $percent')
    );
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
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.file)
    );
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
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Файл'),
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