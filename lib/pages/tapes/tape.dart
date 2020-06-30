import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/widgets/constants.dart';

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
      if (result['message'] == 'Not authenticated' &&result['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        print('Get tape result $result');
        commentCount = result['result']['comments'].length;
        return setTape(result);
      }
    });
    super.initState();
  }

  Future setTape(result) async {
    setState(() {
      // print('this is result $result');
      tapeResult = result["result"];
      com = result["result"]["comments"].toList();
      _future = Future(foo);
    });
  }

  int foo() {
    return 1;
  }
  var _saved = List<dynamic>();

  TextEditingController _commentController = TextEditingController();
  var commentResult;
  var tapeResult;
  List com = [];
  int letterCount = 100;
  var api = Api();
  String tempCount = " ";
  var commentCount;
  int maxLine = 5;
  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    if(_commentController.text.isEmpty)
      letterCount = 100;
    if(_commentController.text.isNotEmpty)
      letterCount = 100 - _commentController.text.length;
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
            color: Color(0xFF001D52),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${localization.comments} : $commentCount',
                            style: TextStyle(color: Color(0xFF001D52), fontWeight: FontWeight.w300),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: com.length,
                              itemBuilder: (context, index) {
                                _saved.add({'index': index, 'maxLines' : 5});
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 10,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,

                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              CircleAvatar(
                                                radius: 15.0,
                                                backgroundImage: NetworkImage('${avatarUrl}${user.avatar}'),
                                                backgroundColor: Colors.red,
                                              ),
                                              
                                            ],
                                          ),
                                          
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                RichText(
                                                  text: TextSpan(
                                                    text: '${com[index]['name']} ',
                                                    style: TextStyle(color: Color(0xFF001D52), fontWeight: FontWeight.w600),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: '${com[index]['comment']}',
                                                        style: TextStyle(color: Color(0xFF001D52), fontWeight: FontWeight.w300),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                 Container(
                                                   padding: EdgeInsets.only(top: 5),
                                                   alignment: Alignment.centerLeft,
                                                   child: Text(
                                                   '${com[index]['date']}',
                                                   overflow: TextOverflow.ellipsis,
                                                   style: TextStyle(color: Color(0xFF5E5E5E), fontWeight: FontWeight.w300),
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
                  backgroundImage: NetworkImage('${avatarUrl}${user.avatar}'),
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
                          if(_commentController.text.isNotEmpty){
                            setState(() {
                              tapeResult.cast<String, dynamic>();
                              commentCount++;
                            });
                            letterCount = 100;
                            await api.addCommentToTape('${_commentController.text}','${widget.tape['id']}',).then((v) {
                              var result = {
                                "avatar": "${user.avatar}",
                                "comment": "${_commentController.text}",
                                "name": "${user.name}",
                                "date": "${v['result']['date']}"
                              };
                              setState(() {
                                com.add(result);
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
                              if(_commentController.text.isNotEmpty){
                                setState(() {
                                  tapeResult.cast<String, dynamic>();
                                  commentCount++;
                                });
                                letterCount = 100;
                                await api.addCommentToTape('${_commentController.text}','${widget.tape['id']}',).then((v) {
                                  print('addCommentResult $v');
                                  var result = {
                                    "avatar": "${user.avatar}",
                                    "comment": "${_commentController.text}",
                                    "name": "${user.name}",
                                    "date": "${v['result']['date']}"
                                  };
                                  setState(() {
                                    com.add(result);
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
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
