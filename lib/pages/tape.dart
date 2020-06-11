import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';

class TapePage extends StatefulWidget {
  final tape;
  TapePage(this.tape);
  @override
  _TapePageState createState() => _TapePageState();
}

class _TapePageState extends State<TapePage>
    with AutomaticKeepAliveClientMixin {
  Future _future;

  @override
  void initState() {
    api.getTape(widget.tape["id"]).then((result) {
      return setTape(result);
    });

    super.initState();
  }

  Future setTape(result) async {
    setState(() {
      print('this is result $result');
      tapeResult = result["result"];
      _future = Future(foo);
    });
  }

  int foo() {
    return 1;
  }

  TextEditingController _commentController = TextEditingController();
  var commentResult;
  var tapeResult;

  int letterCount = 150;
  var api = Api();
  String tempCount = " ";

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        brightness: Brightness.light,
        title: Text(
          "${widget.tape['title']}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                      ),
                      child: Container(
                        color: Color(0xfff7f8fa),
                        padding: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Описание: ${widget.tape['description']}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                              maxLines: 2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Комментарий:'),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: tapeResult['comments'].length,
                              itemBuilder: (context, index) {
                                print(tapeResult['comments'][index]);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 10,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(45.0),
                                            child: Image.network(
                                              'https://indigo24.xyz/uploads/avatars/${tapeResult['comments'][index]['avatar']}',
                                              width: 35.0,
                                              height: 35.0,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                              '${tapeResult['comments'][index]['name']}'),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            '${tapeResult['comments'][index]['comment']}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      height: 0.2,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black,
                                      child: Text('1'),
                                    )
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SafeArea(
        child: Container(
          color: Colors.white,
          padding: keyboardIsOpened == false
              ? EdgeInsets.only(bottom: 20, right: 10, left: 10, top: 10)
              : EdgeInsets.only(bottom: 100, right: 10, left: 10, top: 10),
          margin: EdgeInsets.only(bottom: 0, top: 0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.network(
                      // 'https://indigo24.xyz/uploads/avatars/${db.getItem('own_avatar')}',
                      'https://indigo24.xyz/uploads/avatars/noAvatar.png',
                      width: 35,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10),
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextField(
                          maxLines: 6,
                          minLines: 1,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(151),
                          ],
                          controller: _commentController,
                          onChanged: (value) {
                            if (value.length < tempCount.length) {
                              setState(() {
                                letterCount = letterCount + 1;
                              });
                            }
                            if (value.length > tempCount.length) {
                              setState(() {
                                letterCount = letterCount - 1;
                              });
                            }
                            tempCount = value;
                          },
                          decoration: InputDecoration(
                            // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () async {
                                setState(() {
                                  tapeResult.cast<String, dynamic>();
                                });
                                await api.addCommentToTape(
                                  '${widget.tape['id']}',
                                  '${_commentController.text}',
                                );
                                _commentController.text = "";
                              },
                            ),
                            border: InputBorder.none,
                            hintText: "enter your message",
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   height: 35,
                    //   child: TextFormField(
                    //     inputFormatters: [
                    //       LengthLimitingTextInputFormatter(151),
                    //     ],
                    //     maxLines: 3,
                    //     controller: _commentController,
                    //     onChanged: (value) {
                    //       if (value.length < tempCount.length) {
                    //         setState(() {
                    //           letterCount = letterCount + 1;
                    //         });
                    //       }
                    //       if (value.length > tempCount.length) {
                    //         setState(() {
                    //           letterCount = letterCount - 1;
                    //         });
                    //       }
                    //       tempCount = value;
                    //     },
                    //     decoration: InputDecoration(
                    //       hintText: 'Написать комментарий',
                    //       contentPadding: EdgeInsets.symmetric(
                    //           vertical: 0.0, horizontal: 15.0),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(
                    //           Radius.circular(25.0),
                    //         ),
                    //       ),
                    //       suffixIcon: IconButton(
                    //         icon: Icon(Icons.send),
                    //         onPressed: () async {
                    //           setState(() {
                    //             tapeResult.cast<String, dynamic>();
                    //           });
                    //           await api.addCommentToTape(
                    //             '${widget.tape['id']}',
                    //             '${_commentController.text}',
                    //           );
                    //           _commentController.text = "";
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, bottom: 0, right: 10),
                  child: Text('$letterCount'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}