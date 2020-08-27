import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';

class TapePage extends StatefulWidget {
  final tape;
  TapePage(this.tape);
  @override
  _TapePageState createState() => _TapePageState();
}

class _TapePageState extends State<TapePage>
    with AutomaticKeepAliveClientMixin {
  Future _future;
  var _saved = List<dynamic>();

  TextEditingController _commentController = TextEditingController();
  var _tapeResult;
  List _comments = [];
  int _letterCount = 100;
  Api _api = Api();
  String _tempCount = " ";
  var _commentCount;

  @override
  void initState() {
    _api.getTape(widget.tape["id"]).then((result) {
      if (result['message'] == 'Not authenticated' &&
          result['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        print('Get tape result $result');
        _commentCount = result['result']['comments'].length;
        return setTape(result);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    if (_commentController.text.isEmpty) _letterCount = 100;
    if (_commentController.text.isNotEmpty)
      _letterCount = 100 - _commentController.text.length;
    return Scaffold(
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
        brightness: Brightness.light,
        title: Text(
          "${localization.comments}",
          style: TextStyle(
            color: blackPurpleColor,
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
                        color: milkWhiteColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${localization.comments} : $_commentCount',
                              style: TextStyle(
                                  color: blackPurpleColor,
                                  fontWeight: FontWeight.w300),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                _saved.add({'index': index, 'maxLines': 5});
                               // print('${_comments}');
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 10,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              CircleAvatar(
                                                radius: 15.0,
                                                backgroundImage: NetworkImage(
                                                    '$avatarUrl${_comments[index]['avatar']}'),
                                                backgroundColor: Colors.grey,
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                RichText(
                                                  text: TextSpan(
                                                    text:
                                                        '${_comments[index]['name']} ',
                                                    style: TextStyle(
                                                        color: blackPurpleColor,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text:
                                                            '${_comments[index]['comment']}',
                                                        style: TextStyle(
                                                            color:
                                                                blackPurpleColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(top: 5),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '${_comments[index]['date']}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: darkGreyColor2,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // SizedBox(
                                          // width: 10,
                                          // ),
                                          // InkWell(
                                          //   child: Text('еще'),
                                          //   onTap: (){
                                          //     setState(() {
                                          //       maxLine = 10;
                                          //       _saved[index]['maxLines'] = 1000;
                                          //     });
                                          //     print('eshe');
                                          //   },
                                          //   ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 60,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage('$avatarUrl${user.avatar}'),
                  backgroundColor: Colors.red,
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        maxLines: 6,
                        onSubmitted: (value) async {
                          if (_commentController.text.isNotEmpty) {
                            setState(() {
                              _tapeResult.cast<String, dynamic>();
                              _commentCount++;
                            });
                            _letterCount = 100;
                            await _api
                                .addCommentToTape(
                              '${_commentController.text}',
                              '${widget.tape['id']}',
                            )
                                .then((v) {
                              var result = {
                                "avatar": "${user.avatar}",
                                "comment": "${_commentController.text}",
                                "name": "${user.name}",
                                "date": "${v['result']['date']}"
                              };
                              setState(() {
                                _comments.add(result);
                              });
                            });
                            _commentController.text = "";
                          }
                        },
                        minLines: 1,
                        textInputAction: TextInputAction.go,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        controller: _commentController,
                        onChanged: (value) {
                          if (value.length < _tempCount.length) {
                            setState(() {
                              _letterCount = _letterCount + 1;
                            });
                          }
                          if (value.length > _tempCount.length) {
                            setState(() {
                              _letterCount = _letterCount - 1;
                            });
                          }
                          _tempCount = value;
                        },
                        decoration: InputDecoration(
                          // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              if (_commentController.text.isNotEmpty) {
                                setState(() {
                                  _tapeResult.cast<String, dynamic>();
                                  _commentCount++;
                                });
                                _letterCount = 100;
                                await _api
                                    .addCommentToTape(
                                  '${_commentController.text}',
                                  '${widget.tape['id']}',
                                )
                                    .then((v) {
                                  print('addCommentResult $v');
                                  var result = {
                                    "avatar": "${user.avatar}",
                                    "comment": "${_commentController.text}",
                                    "name": "${user.name}",
                                    "date": "${v['result']['date']}"
                                  };
                                  setState(() {
                                    _comments.add(result);
                                  });
                                });
                                _commentController.text = "";
                              }
                            },
                          ),
                          border: InputBorder.none,
                          hintText: "${localization.enterMessage}",
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, bottom: 10, right: 10),
                  child: Text('$_letterCount'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future setTape(result) async {
    setState(() {
      // print('this is result $result');
      _tapeResult = result["result"];
      _comments = result["result"]["comments"].toList();
      _future = Future(foo);
    });
  }

  int foo() {
    return 1;
  }

  @override
  bool get wantKeepAlive => true;
}
