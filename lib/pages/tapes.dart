import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import 'tape.dart';

class TapesPage extends StatefulWidget {
  @override
  _TapesPageState createState() => _TapesPageState();
}

class _TapesPageState extends State<TapesPage>
    with AutomaticKeepAliveClientMixin {
  Future<int> _listFuture;
  bool isLoaded = false;
  var api = Api();
  List result;
  ScrollController controller;
  int tapePage = 1;
  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    api.getTapes('$tapePage').then((tapes) {
      return setTapes(tapes);
    });
    super.initState();
  }

  _scrollListener() {
    if (controller.position.extentAfter <= 0 && !isLoaded) {
      tapePage += 1;
      setState(() {
        isLoaded = true;
      });
      api.getTapes('$tapePage').then((tapes) {
        print("PAGE $tapePage $tapes");
        return addTapes(tapes);
      });
    }
  }

  Future addTapes(tapes) async {
    setState(() {
      var r = tapes["result"].toList();
      result.addAll(r);
      isLoaded = false;
    });
  }

  Future setTapes(tapes) async {
    setState(() {
      result = tapes["result"].toList();
      _listFuture = Future(foo);
      result.forEach((el) async {
        if (el['myLike'] == true) {
          _saved.add(el['id']);
        }
      });
    });
  }

  int foo() {
    return 1;
  }

  var likeResult;
  var commentResult;

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_scrollListener);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  final Set _saved = Set();
  VideoPlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.light,
        title: Text(
          "Лента",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: FutureBuilder(
            future: _listFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData == true)
                return ListView.builder(
                  reverse: false,
                  itemCount: result.length,
                  controller: controller,
                  itemBuilder: (BuildContext context, int index) {
                    // if (result[index]['media'].endsWith('mp4')) {
                    //   print(result[index]['media']);
                    //   _controller =
                    //       VideoPlayerController.network(result[index]['media'])
                    //         ..initialize().then((_) {
                    //           print('inited');
                    //           setState(() {});
                    //         });
                    // }
                    if (result[index]['media'].endsWith('mp4'))
                      return Container();
                    return Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Container(
                              color: Color(0xfff7f8fa),
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          child: Image.network(
                                            // 'https://media.indigo24.com/avatars/${result[index]['avatar']}',
                                            'https://indigo24.xyz/uploads/avatars/${result[index]['avatar']}',
                                            width: 35,
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              '${result[index]['title']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onDoubleTap: () async {
                                      await api
                                          .likeTape('${result[index]['id']}')
                                          .then((value) {
                                        likeResult = value;
                                      });
                                      setState(() {
                                        if (likeResult['result']['myLike']) {
                                          _saved.add(result[index]['id']);
                                          result[index]['likesCount'] += 1;
                                          final snackBar = SnackBar(
                                            elevation: 200,
                                            duration: Duration(seconds: 2),
                                            content: Text(
                                              'Вы лайнули пост ${result[index]['title']} от ${result[index]['name']}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            backgroundColor: Colors.blue,
                                          );
                                          Scaffold.of(context)
                                              .showSnackBar(snackBar);
                                        } else {
                                          _saved.remove(result[index]['id']);
                                          result[index]['likesCount'] -= 1;
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: PhotoView(
                                          imageProvider: NetworkImage(
                                            "https://indigo24.xyz/uploads/tapes/${result[index]['media']}",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: _saved
                                                  .contains(result[index]['id'])
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 35,
                                        ),
                                        onPressed: () async {
                                          await api
                                              .likeTape(
                                                  '${result[index]['id']}')
                                              .then((value) {
                                            print(value);
                                            setState(() {
                                              likeResult = value;
                                            });
                                          });

                                          setState(() {
                                            if (likeResult['result']
                                                ['myLike']) {
                                              _saved.add(result[index]['id']);
                                              result[index]['likesCount'] += 1;
                                            } else {
                                              _saved
                                                  .remove(result[index]['id']);
                                              result[index]['likesCount'] -= 1;
                                            }
                                          });
                                        },
                                      ),
                                      Container(
                                        width: 30,
                                        child: Text(
                                          '${result[index]['likesCount']}',
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.comment,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TapePage(result[index]),
                                            ),
                                          );
                                        },
                                      ),
                                      Container(
                                        width: 30,
                                        child: Text(
                                          '${result[index]['commentsCount']}',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(''),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          '${result[index]['created']}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      '${result[index]['description']}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            // child: Image.network(
                                            //   'https://indigo24.xyz/uploads/avatars/${db.getItem('own_avatar')}',
                                            //   width: 35,
                                            // ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              else
                return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
