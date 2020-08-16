import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/full_photo.dart';
import 'package:indigo24/widgets/player.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/localization.dart' as localization;

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

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
