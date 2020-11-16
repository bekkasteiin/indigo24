import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:video_player/video_player.dart';
import 'package:indigo24/services/localization.dart' as localization;

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
  final String text;
  PDFViewer(this.file, {@required this.text});

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int _actualPageNumber = 1;
  int _allPagesCount = 0;
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
            title: Text(
              "${widget.text}",
              style: TextStyle(
                color: blackPurpleColor,
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PdfView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        width: 1,
                        color: blackPurpleColor,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_before,
                        color: blackPurpleColor,
                      ),
                      onPressed: () {
                        _pdfController.previousPage(
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 100),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Text(
                      ' $_actualPageNumber / $_allPagesCount',
                      style: TextStyle(
                        fontSize: 22,
                        color: blackPurpleColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: blackPurpleColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        width: 1,
                        color: blackPurpleColor,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.navigate_next,
                        color: whiteColor,
                      ),
                      onPressed: () {
                        _pdfController.nextPage(
                          curve: Curves.ease,
                          duration: Duration(milliseconds: 100),
                        );
                      },
                    ),
                  ),
                  Container(height: 100),
                ],
              ),
            ],
          ),
        ),
      );
}
