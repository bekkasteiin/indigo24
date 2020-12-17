import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/pages/tabs/tabs.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_search_widget.dart';

class ChatMembersSelection extends StatefulWidget {
  final chatId;
  final currentChatMembers;

  ChatMembersSelection(this.chatId, this.currentChatMembers);

  @override
  _ChatMembersSelectionState createState() => _ChatMembersSelectionState();
}

class _ChatMembersSelectionState extends State<ChatMembersSelection> {
  List _saved;

  TextEditingController _searchController;

  List _actualList = List<dynamic>();

  @override
  void initState() {
    super.initState();

    _saved = List<dynamic>();
    _searchController = TextEditingController();

    _actualList.addAll(myContacts);

    _listen();
  }

  @override
  void dispose() async {
    super.dispose();
    _searchController.dispose();
    await subscription.cancel();
  }

  StreamSubscription subscription;

  _listen() {
    subscription = ChatRoom.shared.contactStream.listen((e) {
      var cmd = e.json['cmd'];
      print("MEMBER SELECTION EVENT $cmd");
      if (ModalRoute.of(context).isCurrent) {
        switch (cmd) {
          case "user:check":
            if ("${e.json['data']['chat_id']}" != "null" &&
                "${e.json['data']['status']}" == 'true') {
              setState(() {
                _saved.add({
                  'phone': e.json['data']['phone'],
                  'user_id': e.json['data']['user_id'],
                  'name': e.json['data']['name'],
                });
              });
            }
            break;
          case "chat:members:add":
            Navigator.pop(context);
            break;
          default:
            print('this is default');
        }
      }
    });
  }

  void _search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      myContacts.forEach((item) {
        if (item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.phone.toLowerCase().contains(query.toLowerCase())) {
          matches.add(item);
        }
      });
      setState(() {
        _actualList.clear();
        _actualList.addAll(matches);
      });
    } else {
      setState(() {
        _actualList.clear();
        _actualList.addAll(myContacts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${localization.addToGroup}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.group_add),
            iconSize: 30,
            color: blackPurpleColor,
            onPressed: () {
              String userIds = '';
              _saved.forEach((element) {
                userIds += '${element['user_id']}' + ',';
              });
              userIds = userIds.substring(0, userIds.length - 1);
              ChatRoom.shared.addMembers('${widget.chatId}', '$userIds');
            },
          )
        ],
      ),
      body: myContacts.isNotEmpty
          ? SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text('${_saved.length} ${localization.contacts}'),
                  ),
                  Container(
                    height: _saved.length == 0 ? 0 : 82,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _saved.length != null ? _saved.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: <Widget>[
                            Container(
                              width: 80,
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Container(
                                      color: primaryColor,
                                      width: 35,
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          '${_saved[index]['name'][0].toUpperCase()}',
                                          style: TextStyle(
                                            color: whiteColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      '${_saved[index]['name']}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _saved[index]['user_id'] == '${user.id}'
                                ? Center()
                                : Positioned(
                                    bottom: 30,
                                    right: 20,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        border: Border.all(
                                          color: primaryColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      width: 22,
                                      height: 22,
                                      child: Center(
                                        child: Center(
                                          child: InkWell(
                                            child: Icon(
                                              Icons.close,
                                              size: 14,
                                              color: primaryColor,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _saved.removeWhere((item) {
                                                  print(item);
                                                  return '${item['phone']}' ==
                                                      '${_saved[index]['phone']}';
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: _actualList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if ('${user.phone}' == '+${_actualList[index].phone}')
                          return Center();
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            child: CheckboxListTile(
                              title: Wrap(
                                children: <Widget>[
                                  Text(
                                    '${_actualList[index].name}',
                                    style: TextStyle(fontSize: 16.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${_actualList[index].phone}',
                                style: TextStyle(fontSize: 14.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: _value(index),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    ChatRoom.shared
                                        .userCheck(_actualList[index].phone);
                                  } else {
                                    _saved.removeWhere((item) {
                                      return '${item['phone']}' ==
                                          '${_actualList[index].phone}';
                                    });
                                  }
                                });
                              },
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: whiteColor,
                            ),
                            margin: EdgeInsets.only(left: 10, right: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  _value(index) {
    bool tempo = false;
    _saved.forEach((element) {
      if ('${element['phone']}' == '${_actualList[index].phone}') {
        tempo = true;
      }
    });
    return tempo;
  }
}
