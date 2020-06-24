import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:indigo24/pages/chat/chat.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
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
        title: InkWell(
          child: Column(
            children: <Widget>[
              Text('Медиафайлы',
                style: TextStyle(
                    color: Color(0xFF001D52), fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
              ),
            ]),
        ),
      ),
body: SafeArea(child: FullPhotoScreen(url: url)),
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

  itemCounter(){
    int c = 0;
    for(int i=0; i<listMessages.length; i++){
      if(listMessages[i]['type'].toString()=='1'){
        c = c + 1;
        tempList.add(listMessages[i]);
      }
    }
    print("ITEM counter ${tempList[0]}");
    return c;
  }
  Future movingToIndex(i) async {
    return _controller.move(i, animation: false,);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: new Swiper(
              loop: false,
              itemCount: itemCounter(),
              itemBuilder: (BuildContext context,int index){
                print(tempList[index]);
                var a = jsonDecode(tempList[index]['attachments']);
                var url1 = '${tempList[index]['attachment_url']}${a[0]['filename']}';

                return Image(
                  image: CachedNetworkImageProvider(currentIndex==null?url:url1)
                );
              },
              onIndexChanged: (i){
                setState(() {
                  currentIndex = i;
                });
              },
              controller: _controller,
            )
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemCounter(),
              itemBuilder: (context, i){
                if(tempList[i]['type'].toString()=='1'){
                  var a = jsonDecode(tempList[i]['attachments']);
                
                  var url1 = '${tempList[i]['attachment_url']}${a[0]['filename']}';
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        currentIndex = i;
                        _controller.move(i);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Image(
                  image: CachedNetworkImageProvider(currentIndex==null?url:url1)
                )
                      // Text('hi'),
                      // child: Image(
                      //   image: CachedNetworkImageProvider(url1),
                      //   fit: BoxFit.fitHeight,
                      // ),
                    ),
                  );
                }
              },
            )
          )
        ],
      )
    );
  }
}