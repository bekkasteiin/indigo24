import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';

import '../../main.dart';
import 'chat.dart';
import 'chat_contacts.dart';

class ChatGroupSelection extends StatefulWidget {
  @override
  _ChatGroupSelectionState createState() => _ChatGroupSelectionState();
}

class _ChatGroupSelectionState extends State<ChatGroupSelection> {
  var _selectedsList = List<dynamic>();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  var _actualList = List<dynamic>();
  @override
  void initState() {
    super.initState();
    _actualList.addAll(myContacts);
    ChatRoom.shared.setContactsStream();
    _selectedsList.add({
      "phone": "${user.phone}",
      "user_id": "${user.id}",
      "name": "${user.name}"
    });
    _listen();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _titleController.dispose();
    // ChatRoom.shared.contactController.close();
  }

  _listen() {
    ChatRoom.shared.onContactChange.listen((e) {
      print("GROUP SELECTION EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "chat:create":
          print("STATUS ${e.json["data"]["status"]}");
          if (e.json["data"]["status"].toString() == "true") {
            var name = e.json["data"]["chat_name"];
            var chatID = e.json["data"]["chat_id"];
            print(e.json['data']['type']);
            // ChatRoom.shared.setChatStream();
            ChatRoom.shared.getMessages(chatID);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  avatar: e.json['data']['avatar'],
                  chatName: name,
                  chatId: chatID,
                  memberCount: e.json['data']['members_count'],
                  avatarUrl: 'https://indigo24.com/uploads/avatars/',
                  chatType: e.json['data']['type'],
                ),
              ),
            ).whenComplete(() {
              ChatRoom.shared.closeChatStream();
            });
          } else {
            print('++++++++++++++++++++');

            // Navigator.pop(context);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
            // ).whenComplete(() {
            //   ChatRoom.shared.closeCabinetStream();
            // });
          }
          break;

        default:
      }
    });
  }

  Future<void> _showError(BuildContext context, m) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('${localization.error}'),
          content: Text(m),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            "${localization.createGroup}",
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
                  if (_selectedsList.length > 2) {
                    if (_titleController.text.isNotEmpty) {
                      String userIds = '';
                      _selectedsList.removeAt(0);
                      _selectedsList.forEach((element) {
                        userIds += '${element['user_id']}' + ',';
                        print(element);
                      });
                      print(userIds);
                      userIds = userIds.substring(0, userIds.length - 1);
                      ChatRoom.shared.cabinetCreate(userIds, 1,
                          title: _titleController.text);
                    } else {
                      print('chat name is empty');
                      _showError(context, '${localization.noChatName}');
                    }
                  } else {
                    print('member count less than 3');
                    _showError(context, '${localization.minMembersCount}');
                  }
                })
          ],
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                      '${_selectedsList.length} ${localization.contacts}')),
              Container(
                height: _selectedsList.length == 0 ? 0 : 82,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedsList.length != null
                      ? _selectedsList.length
                      : 0,
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
                                      '${_selectedsList[index]['name'][0].toUpperCase()}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                  // '${_saved2[index]['data']['data']['name']} asd',
                                  '${_selectedsList[index]['name']}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              // Text("${_saved2[index][0]}")
                            ],
                          ),
                        ),
                        _selectedsList[index]['user_id'] == '${user.id}'
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
                                              _selectedsList
                                                  .removeWhere((item) {
                                                return '${item['phone']}' ==
                                                    '${_selectedsList[index]['phone']}';
                                              });
                                            });
                                          },
                                        ),
                                      ),
                                    )),
                              ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                child: TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(40),
                  ],
                  decoration: InputDecoration(
                    hintText: "${localization.chatName}",
                    fillColor: Colors.white,
                  ),
                  controller: _titleController,
                ),
              ),
              Container(
                height: 50,
                padding:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                child: Center(
                  child: TextField(
                    decoration: InputDecoration(
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
              _actualList.isNotEmpty
                  ? Flexible(
                      child: ListView.builder(
                        itemCount: _actualList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          if (_actualList[index].phone == null &&
                              _actualList[index].name == null)
                            return Container();
                          if ('${user.phone}' ==
                              '+${_actualList[index].phone}') return Center();
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
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedsList.add({
                                        'phone': _actualList[index].phone,
                                        'user_id': _actualList[index].id,
                                        'name': _actualList[index].name,
                                      });
                                    } else {
                                      _selectedsList.removeWhere((item) {
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
                              margin: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text('${localization.emptyContacts}'),
                    ),
            ],
          ),
        ));
  }

  _value(index) {
    bool tempo = false;
    _selectedsList.forEach((element) {
      if ('${element['phone']}' == '${_actualList[index].phone}') {
        tempo = true;
      }
    });
    return tempo;
  }
}
