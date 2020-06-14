import 'dart:async';
import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;

class ChatGroupSelection extends StatefulWidget {
  @override
  _ChatGroupSelectionState createState() => _ChatGroupSelectionState();
}

class _ChatGroupSelectionState extends State<ChatGroupSelection> {
  var arrays = [];
  final Set _saved = Set();
  final Set _userIds = Set();

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Ошибка"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _future;

  @override
  void initState() {
    _future = getContacts();
    super.initState();
    ChatRoom.shared.setContactsStream();
    listen();
    print('listened');
  }

  var tempIndex = 0;

  listen() {
    ChatRoom.shared.onContactChange.listen((e) {
      print("Contact EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "user:check":
          if ("${e.json['data']['chat_id']}" != "null" &&
              "${e.json['data']['status']}" == 'true') {
            print(tempIndex);
            setState(() {
              _saved.add(tempIndex);
            });
            print('${e.json['data']}');
            _userIds.add('${e.json['data']['user_id']}');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => ChatPage(
            //           e.json['data']['user_id'], e.json['data']['chat_id'])),
            // ).whenComplete(() {
            //   ChatRoom.shared.forceGetChat();
            //   ChatRoom.shared.closeCabinetStream();
            // });
          } else if (e.json['data']['status'] == 'true') {
            // ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
          }
          break;
        case "chat:create":
          print("STATUS ${e.json["data"]["status"]}");
          if (e.json["data"]["status"].toString() == "true") {
            var name = e.json["data"]["chat_name"];
            var chatID = e.json["data"]["chat_id"];
            print('${e.json["data"]}');
            ChatRoom.shared.setCabinetStream();
            ChatRoom.shared.getMessages('$chatID');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(name, chatID,
                      memberCount: e.json["data"]['members_count'])),
            ).whenComplete(() {
              ChatRoom.shared.closeCabinetStream();
            });
          } else {
            var name = e.json["data"]["name"];
            var chatID = e.json["data"]["chat_id"];
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
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(m),
          actions: <Widget>[
            FlatButton(
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

  @override
  void dispose() {
    super.dispose();
    ChatRoom.shared.contactController.close();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  String formatPhone(String phone) {
    String r = phone.replaceAll(" ", "");
    r = r.replaceAll("(", "");
    r = r.replaceAll(")", "");
    r = r.replaceAll("+", "");
    r = r.replaceAll("-", "");
    if (r.startsWith("8")) {
      r = r.replaceFirst("8", "7");
    }
    return r;
  }

  var _contacts = [];
  Future getContacts() async {
    try {
      _contacts.clear();
      if (await Permission.contacts.request().isGranted) {
        Iterable<Contact> phonebook = await ContactsService.getContacts();
        phonebook.forEach((el) {
          if (el.displayName != null) {
            el.phones.forEach((phone) {
              String contact = formatPhone(phone.value);
              if (!_contacts.contains(contact)) {
                phone.value = formatPhone(phone.value);
                _contacts.add({
                  'name': el.displayName,
                  'phone': phone.value,
                });
              }
            });
          }
        });
      }
      setState(() {
        actualList.addAll(_contacts);
      });
      return _contacts;
    } catch (_) {
      print(_);
      return "disconnect";
    }
  }

  TextEditingController _searchController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  var actualList = List<dynamic>();

  void search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      _contacts.forEach((item) {
        if (item['name'].toLowerCase().contains(query.toLowerCase()) ||
            item['phone'].toLowerCase().contains(query.toLowerCase())) {
          matches.add(item);
        }
      });
      setState(() {
        actualList.clear();
        actualList.addAll(matches);
      });
      return;
    } else {
      setState(() {
        actualList.clear();
        actualList.addAll(_contacts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
       
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
                  "Создать группу",
                  style: TextStyle(
                    color: Color(0xFF001D52),
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.group_add),
                      iconSize: 30,
                      color: Color(0xFF001D52),
                      onPressed: () {
                        if (_userIds.length > 1) {
                          if (_titleController.text.isNotEmpty) {
                            ChatRoom.shared.cabinetCreate(
                              _userIds.join(','),
                              1,
                              title: _titleController.text,
                            );
                          } else {
                            print('chat name is empty');
                            _showError(context, 'Отсутствует название чата');
                          }
                        } else {
                          print('member count less than 3');
                          _showError(
                              context, 'Минимальное количество участников : 3');
                        }
                      })
                ],
                backgroundColor: Colors.white,
              ),
              body: snapshot.hasData
                  ? Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10, bottom: 0),
                          child: TextField(
                            decoration: new InputDecoration(
                              hintText: "Название чата",
                              fillColor: Colors.white,
                            ),
                            controller: _titleController,
                          ),
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10, bottom: 0),
                          child: Center(
                            child: TextField(
                              decoration: new InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFF001D52),
                                ),
                                hintText: "Поиск",
                                fillColor: Color(0xFF001D52),
                              ),
                              onChanged: (value) {
                                search(value);
                              },
                              controller: _searchController,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: actualList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Container(
                                  child: CheckboxListTile(
                                    title: Wrap(
                                      children: <Widget>[
                                        Text(
                                          '${actualList[index]['name']}',
                                          style: TextStyle(fontSize: 16.0),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      '${actualList[index]['phone']}',
                                      style: TextStyle(fontSize: 14.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    value: _saved.contains(index),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          tempIndex = index;
                                          ChatRoom.shared.userCheck(actualList[index]['phone']);
                                        } else {
                                          _saved.remove(index);
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
                    )
                  : Center(child: CircularProgressIndicator()));
      },
    );
  }
}