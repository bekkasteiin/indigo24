import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat/chat_pages/chat_info.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_search_widget.dart';

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
            "${Localization.language.comments}",
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
                        child: IndigoSearchWidget(
                          onChangeCallback: (value) {
                            _search(value);
                          },
                          searchController: _searchController,
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
                                '${Localization.language.likes} : ${_likes.length}',
                                style: TextStyle(
                                    color: blackPurpleColor,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 75,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _actualList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatProfileInfo(
                                              chatType: 0,
                                              chatName: _actualList[index]
                                                  ['name'],
                                              chatAvatar: _actualList[index]
                                                  ['avatar'],
                                              userId: _actualList[index]
                                                  ['customerID'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            child: CachedNetworkImage(
                                              height: 35,
                                              width: 35,
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
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Text(
                                '${Localization.language.comments} : $_commentCount',
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
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatProfileInfo(
                                                          chatType: 0,
                                                          chatName:
                                                              _comments[index]
                                                                  ['name'],
                                                          chatAvatar:
                                                              _comments[index]
                                                                  ['avatar'],
                                                          userId: _comments[
                                                                  index]
                                                              ['customerID'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 15.0,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      '$avatarUrl${_comments[index]['avatar']}',
                                                    ),
                                                    backgroundColor: greyColor,
                                                  ),
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
                                                            FontWeight.w600,
                                                      ),
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
                                          ],
                                        ),
                                      ),
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
            color: whiteColor,
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
                    backgroundColor: greyColor,
                  ),
                  Expanded(
                    child: Container(
                      color: whiteColor,
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
                            hintText: "${Localization.language.enterMessage}",
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
}
