import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

class TapePage extends StatefulWidget {
  final tape;
  TapePage(this.tape);
  @override
  _TapePageState createState() => _TapePageState();
}

class _TapePageState extends State<TapePage> {
  Future _future;
  var _saved = List<dynamic>();

  TextEditingController _commentController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  var _tapeResult;
  List _comments = [];
  List _likes = [];
  List _actualList = [];

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
        _commentCount = result['result']['comments'].length;
        setState(() {
          _likes = result["result"]["likes"].toList();
          _actualList.addAll(_likes);
        });
        return setTape(result);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _searchController.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    if (_commentController.text.isEmpty) _letterCount = 100;
    if (_commentController.text.isNotEmpty)
      _letterCount = 100 - _commentController.text.length;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: IndigoAppBarWidget(
          title: Text(
            "${localization.comments}",
            style: TextStyle(
              color: blackPurpleColor,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10, bottom: 0),
                        child: TextField(
                          decoration: new InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: blackPurpleColor,
                            ),
                            hintText: "${localization.search}",
                            fillColor: blackPurpleColor,
                          ),
                          onChanged: (value) {
                            _search(value);
                          },
                          controller: _searchController,
                        ),
                      ),
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
                                '${localization.likes} : ${_likes.length}',
                                style: TextStyle(
                                    color: blackPurpleColor,
                                    fontWeight: FontWeight.w300),
                              ),
                              Container(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _actualList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          child: CachedNetworkImage(
                                            height: 50,
                                            width: 50,
                                            imageUrl: avatarUrl +
                                                _actualList[index]['avatar'],
                                          ),
                                        ),
                                        Container(
                                          width: 70,
                                          child: Center(
                                            child: Text(
                                              _actualList[index]['name']
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: blackPurpleColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
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
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                          color:
                                                              blackPurpleColor,
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
                    backgroundColor: Colors.grey,
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
      ),
    );
  }

  _search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      _likes.forEach((item) {
        if (item['name'] != null) {
          if (item['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
            matches.add(item);
          }
        }
      });
      setState(() {
        _actualList = [];
        _actualList.addAll(matches);
      });
      return;
    } else {
      setState(() {
        _actualList = [];
        _actualList.addAll(_likes);
      });
    }
  }

  Future setTape(result) async {
    setState(() {
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
