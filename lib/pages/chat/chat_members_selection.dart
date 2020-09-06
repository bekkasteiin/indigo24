import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';

import '../../main.dart';
import 'chat_contacts.dart';

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

  List _actualList;
  @override
  void initState() {
    super.initState();

    _saved = List<dynamic>();
    _searchController = TextEditingController();

    _actualList = myContacts;

    ChatRoom.shared.setContactsStream();

    _listen();
  }

  @override
  void dispose() {
    super.dispose();
    // ChatRoom.shared.contactController.close();
    _searchController.dispose();
  }

  _listen() {
    ChatRoom.shared.onContactChange.listen((e) {
      var cmd = e.json['cmd'];
      print("MEMBER SELECTION EVENT $cmd");
      print(e.json);
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
            print('______CHAT MEMBERS ADD______');
            // Navigator.pop(context);
            Navigator.pop(context);
            ChatRoom.shared.getMessages(widget.chatId);
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
      appBar: AppBar(
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
        centerTitle: true,
        brightness: Brightness.light,
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
        backgroundColor: Colors.white,
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
                                            color: Colors.white,
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
                                        color: Colors.white,
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
                                                  return '${item.phone}' ==
                                                      '${_saved[index].phone}';
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
                  Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: 0,
                    ),
                    child: Center(
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
                              color: Colors.white,
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
