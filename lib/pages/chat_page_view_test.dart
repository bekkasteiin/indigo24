import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/full_photo.dart';
import 'package:indigo24/services/socket.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/widgets/player.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

var parser = EmojiParser();

class ChatPageView extends StatefulWidget {
  final String username;

  const ChatPageView({
    Key key,
    this.username,
  }) : super(key: key);

  @override
  _ChatPageViewState createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];

  @override
  void initState() {
    super.initState();
    childList.add(Align(
      alignment: Alignment(1, 0),
      child: SendedMessageWidget(
        content: 'Hello',
        time: '21:36 PM',
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 65,
                    child: Container(
                      color: Colors.red,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                widget.username ?? "Jimi Cooke",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Text(
                                "online",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                            child: Container(
                              child: ClipRRect(
                                child: Container(
                                    child: SizedBox(), color: Colors.orange),
                                borderRadius: new BorderRadius.circular(50),
                              ),
                              height: 55,
                              width: 55,
                              padding: const EdgeInsets.all(0.0),
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        spreadRadius: -1,
                                        offset: Offset(0.0, 5.0))
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black54,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    // height: 500,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                'https://i.pinimg.com/564x/6a/50/87/6a508713052ffb6f1686f7441800e34e.jpg'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.linearToSrgbGamma()),
                      ),
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          reverse: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: childList,
                          )),
                    ),
                  ),
                  Divider(height: 0, color: Colors.black26),
                  // SizedBox(
                  //   height: 50,
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        maxLines: 6,
                        minLines: 1,
                        controller: _text,
                        decoration: InputDecoration(
                          // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              print(_text.text);
                              setState(() {
                                childList.add(Align(
                                  alignment: Alignment(1, 0),
                                  child: SendedMessageWidget(
                                    content: _text.text,
                                    time: '22:40 PM',
                                  ),
                                ));
                                _text.text = '';
                              });
                            },
                          ),
                          border: InputBorder.none,
                          hintText: "enter your message",
                        ),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          date,
          style: TextStyle(fontSize: 16, color: Color(0xFF5E5E5E)),
        )),
      ),
    );
  }
}

class SendedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  final String write;
  final String media;
  final String mediaUrl;
  final String rMedia;
  final String type;
  const SendedMessageWidget({
    Key key,
    this.content,
    this.time,
    this.write,
    this.media,
    this.mediaUrl,
    this.rMedia,
    this.type
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    var a = parser.unemojify(content);
    int l = a.length-1;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 120.0,
      ),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
              right: 8.0, left: 50.0, top: 4.0, bottom: 4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15)),
            child: Container(
              color: Colors.white,
              child: Stack(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      right: 12.0, left: 8.0, top: 8.0, bottom: 15.0),
                  child: (a[0]==":" && a[l]==":" && content.length<9)?
                  Text(content, style: TextStyle(fontSize: 40))
                  :
                  (a[0]==":" && a[l]==":" && content.length>8)?
                  Text(content, style: TextStyle(fontSize: 24))
                  :
                  (type=="1")?
                  ImageMessage(mediaUrl+rMedia, "$mediaUrl$media")
                  :
                  (type=="2")?
                  FileMessage(url:"$mediaUrl$media")
                  :
                  (type=="3")?
                  new AudioMessage("$mediaUrl$media")
                  :
                  (type=="4")?
                  new VideoMessage("$mediaUrl$media")
                  :
                  Text(
                    content,
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: 3,
                  child: write == '1'
                      ? Icon(
                          Icons.done_all,
                          size: 16,
                          color: Colors.blue,
                        )
                      : Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                ),
                Positioned(
                  bottom: 1,
                  left: 10,
                  child: Text(
                    time,
                    style: TextStyle(
                        fontSize: 10, color: Colors.black.withOpacity(0.6)),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ReceivedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  final String image;
  final String name;
  final String media;
  final String mediaUrl;
  final String rMedia;
  final String type;

  const ReceivedMessageWidget({
    Key key,
    this.content,
    this.time,
    this.image,
    this.name,
    this.media,
    this.mediaUrl,
    this.rMedia,
    this.type
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var a = parser.unemojify(content);
    int l = a.length-1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 5),
        CircleAvatar(
          backgroundImage: NetworkImage(image),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: image,
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl: "https://media.indigo24.com/avatars/noAvatar.png"
              )
            ),
          ),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130.0,
            ),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 75.0, left: 8.0, top: 8.0, bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Container(
                    color: Color(0xFFFFFFFF),
                    child: Stack(children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 5.0, bottom: 0.0),
                            child: Text(name, style: TextStyle(color: Colors.amber,fontWeight: FontWeight.w500)),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 0.0, bottom: 15.0),
                            child: (a[0]==":" && a[l]==":" && content.length<9)?
                            Text(content, style: TextStyle(fontSize: 40))
                            :
                            (a[0]==":" && a[l]==":" && content.length>8)?
                            Text(content, style: TextStyle(fontSize: 24))
                            :
                            (type=="1")?
                            ImageMessage("$mediaUrl$rMedia", "$mediaUrl$media")
                            :
                            (type=="2")?
                            FileMessage(url:"$mediaUrl$media")
                            :
                            (type=="3")?
                            new AudioMessage("$mediaUrl$media")
                            :
                            (type=="4")?
                            new VideoMessage("$mediaUrl$media")
                            :
                            Text(
                              content,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 1,
                        right: 10,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      )
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


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
  ImageMessage(this.imageUrl, this.fullImageUrl);

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
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                // valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
              // width: 200.0,
              // height: 200.0,
              width: MediaQuery.of(context).size.width*0.7,
              height: MediaQuery.of(context).size.width*0.7,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'assets/loading.gif',
                // width: 200.0,
                // height: 200.0,
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
          print('hi');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FullPhoto(url: imageUrl)));
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
   
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PDFViewer(raf.path)),
      );
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