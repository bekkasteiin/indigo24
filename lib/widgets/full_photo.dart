import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:indigo24/services/localization.dart' as localization;

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: previewBackgoundProvider)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.white.withOpacity(0.2),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(10),
              child: Image(
                image: AssetImage(
                  'assets/images/backWhite.png',
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InkWell(
            child: Column(children: <Widget>[
              Text(
                'Медиафайлы',
                style: TextStyle(
                    color: Color(0xFFffffff), fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
        ),
        body: SafeArea(child: FullPhotoScreen(url: url)),
      ),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => new FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;
  SwiperController _controller;
  int currentIndex = 0;

  FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
    _controller = new SwiperController();
  }

  List tempList = [];

  itemCounter() {
    int c = 0;
    for (int i = 0; i < listMessages.length; i++) {
      if (listMessages[i]['type'].toString() == '1') {
        c = c + 1;
        tempList.add(listMessages[i]);
      }
    }
    print("ITEM counter ${tempList[0]}");
    return c;
  }

  Future movingToIndex(i) async {
    return _controller.move(
      i,
      animation: false,
    );
  }

  var url1;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Container(
              color: Colors.white.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                    child: Row(
                      children: [
                        Text(
                          "${localization.save} ",
                          style: TextStyle(color: Colors.white),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Image.asset(
                          "assets/images/download.png",
                          width: 20,
                        )
                      ],
                    ),
                    onPressed: () {
                      _saveNetworkImage(currentIndex == null ? url : url1);
                    },
                  ),
                  FlatButton(
                    child: Row(
                      children: [
                        Text(
                          "${localization.share} ",
                          style: TextStyle(color: Colors.white),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Image.asset(
                          "assets/images/upload.png",
                          width: 20,
                        )
                      ],
                    ),
                    onPressed: () {
                      Share.share(currentIndex == null ? url : url1,
                          subject: '${localization.photo}');
                    },
                  ),
                ],
              ),
            )),
        Expanded(
            flex: 10,
            child: new Swiper(
              loop: false,
              itemCount: itemCounter(),
              itemBuilder: (BuildContext context, int index) {
                var a = jsonDecode(tempList[index]['attachments']);
                url1 =
                    '${tempList[index]['attachment_url']}${a[0]['filename']}';

                return PhotoView(
                  imageProvider: CachedNetworkImageProvider(
                      currentIndex == null ? url : url1),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                );
              },
              onIndexChanged: (i) {
                setState(() {
                  currentIndex = i;
                });
              },
              controller: _controller,
            )),
        Expanded(
            flex: 2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCounter(),
              itemBuilder: (context, i) {
                if (tempList[i]['type'].toString() == '1') {
                  var a = jsonDecode(tempList[i]['attachments']);

                  var url1 =
                      '${tempList[i]['attachment_url']}${a[0]['filename']}';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                        _controller.move(i);
                      });
                    },
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Image(
                            image: CachedNetworkImageProvider(
                                currentIndex == null ? url : url1))
                        // Text('hi'),
                        // child: Image(
                        //   image: CachedNetworkImageProvider(url1),
                        //   fit: BoxFit.fitHeight,
                        // ),
                        ),
                  );
                }
              },
            ))
      ],
    ));
  }

  void _saveNetworkImage(url) async {
    GallerySaver.saveImage(url).then((bool success) {
      if (success)
        setState(() {
          showAlertDialog(context, "${localization.success}", "${localization.uploaded}");
          print('Image is saved');
        });
      else
        showAlertDialog(context, "${localization.error}", "${localization.somethingWentWrong}");
    });
  }

  showAlertDialog(BuildContext context, String title, String message) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("$title"),
      content: Text("$message"),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
