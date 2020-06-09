import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';

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
  
  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    api.getTapes('1').then((tapes) {

      return setTapes(tapes);
    });

    super.initState();
  }

  _scrollListener() {
    print("${controller.position.extentAfter} $isLoaded");
    if (controller.position.extentAfter <= 0 && !isLoaded) {
      setState(() {
        isLoaded = true;
      });

      api.getTapes('2').then((tapes) {
        print("PAGE 2 $tapes");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    return Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: Container(
                            color: Color(0xfff7f8fa),
                            // color: Colors.yellow,
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
                                          'https://media.indigo24.com/avatars/noAvatar.png',
                                          width: 35,
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10.0),
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
                                            'Вам лайкнули пост ${result[index]['title']} от ${result[index]['name']}',
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
                                  child: Center(
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/loading.gif',
                                      image:
                                          // 'https://image.freepik.com/free-photo/colorful-paper-flowers-background_44527-808.jpg',
                                          'https://indigo24.xyz/uploads/tapes/${result[index]['media']}',
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color:
                                            _saved.contains(result[index]['id'])
                                                ? Colors.red
                                                : Colors.grey,
                                        size: 35,
                                      ),
                                      onPressed: () async {
                                        await api
                                            .likeTape('${result[index]['id']}')
                                            .then((value) {
                                          print(value);
                                          setState(() {
                                            likeResult = value;
                                          });
                                        });

                                        setState(() {
                                          if (likeResult['result']['myLike']) {
                                            _saved.add(result[index]['id']);
                                            result[index]['likesCount'] += 1;
                                          } else {
                                            _saved.remove(result[index]['id']);
                                            result[index]['likesCount'] -= 1;
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                      '${result[index]['likesCount']}',
                                    ),
                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.share,
                                    //     size: 35,
                                    //   ),
                                    //     onPressed: () {},
                                    // ),
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
                                  padding: const EdgeInsets.only(bottom: 10.0),
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
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 10),
                                          child: FlatButton(
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(height: 20),
                                                Container(
                                                  height: 35,
                                                  child: Text(
                                                    'Написать комментарий',
                                                  ),
                                                ),
                                              ],
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
