import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:indigo24/services/localization/localization.dart';

import '../alerts/indigo_alert.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: previewBackgoundProvider,
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Scaffold(
        backgroundColor: transparentColor,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: whiteColor.withOpacity(0.2),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: whiteColor,
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
                style:
                    TextStyle(color: whiteColor, fontWeight: FontWeight.w400),
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
    // for (int i = 0; i < listMessages.length; i++) {
    //   if (listMessages[i]['type'].toString() == '1') {
    //     c = c + 1;
    //     tempList.add(listMessages[i]);
    //   }
    // }
    return c;
  }

  Future movingToIndex(i) async {
    return _controller.move(
      i,
      animation: false,
    );
  }

  var url1;
  int inter = 4;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Container(
              color: whiteColor.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                    child: Row(
                      children: [
                        Text(
                          "${Localization.language.save} ",
                          style: TextStyle(color: whiteColor),
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
                      _saveNetworkImage(url);
                      // _saveNetworkImage(currentIndex == null ? url : url1);
                    },
                  ),
                  FlatButton(
                    child: Row(
                      children: [
                        Text(
                          "${Localization.language.share} ",
                          style: TextStyle(color: whiteColor),
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
                      Share.share(url,
                          subject: '${Localization.language.photo}');
                      // Share.share(currentIndex == null ? url : url1,
                      //                       subject: '${Localization.language.photo}');
                    },
                  ),
                ],
              ),
            )),
        Expanded(
          flex: 10,
          child: Swiper(
            loop: false,
            itemCount: 1,
            // itemCount: itemCounter(),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    RotatedBox(
                      quarterTurns: inter,
                      child: PhotoView(
                        imageProvider: CachedNetworkImageProvider(url),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 3,
                        backgroundDecoration:
                            BoxDecoration(color: transparentColor),
                      ),
                    ),
                    Container(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.rotate_right,
                            color: whiteColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (inter == 4) {
                                inter = 1;
                              } else {
                                inter = 4;
                              }
                            });
                          },
                        ))
                  ],
                ),
              );
            },
            onIndexChanged: (i) {
              setState(() {
                currentIndex = i;
              });
            },
            controller: _controller,
          ),
        ),
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
                } else {
                  return Center();
                }
              },
            ))
      ],
    ));
  }

  void _saveNetworkImage(url) async {
    GallerySaver.saveImage(url).then((bool success) {
      setState(() {});
      if (success)
        setState(() {
          showAlertDialog(context, "${Localization.language.success}",
              "${Localization.language.uploaded}");
        });
      else
        showAlertDialog(context, "${Localization.language.error}",
            "${Localization.language.somethingWentWrong}");
    });
  }

  showAlertDialog(BuildContext context, String title, String message) {
    showIndigoDialog(
      context: context,
      builder: CustomDialog(
        description: "$message",
        yesCallBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
