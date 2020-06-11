import 'dart:async';
import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:indigo24/services/socket.dart';

class ChatContactsPage extends StatefulWidget {
  @override
  _ChatContactsPageState createState() => _ChatContactsPageState();
}

class _ChatContactsPageState extends State<ChatContactsPage> {
  var arrays = [];

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
  }
  listen() {
    ChatRoom.shared.onContactChange.listen((e) {
      print("Contact EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "user:check":
            ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
          break;
        case "chat:create":
          print("STATUS ${e.json["data"]["status"]}");
          if(e.json["data"]["status"].toString() == "true"){
            var name = e.json["data"]["chat_name"];
            var chatID = e.json["data"]["chat_id"];
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
            ).whenComplete(() {
              ChatRoom.shared.closeCabinetStream();
            });
          } else {
            var name = e.json["data"]["name"];
            var chatID = e.json["data"]["chat_id"];
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
            ).whenComplete(() {
              ChatRoom.shared.closeCabinetStream();
            });
          }
          break;

        default:
      }
    });
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
        if (snapshot.hasData == true) {
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerTitle: true,
                brightness: Brightness.light,
                title: Text(
                  "Контакты",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                              hintText: "Поиск",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderSide: new BorderSide(),
                              ),
                            ),
                            onChanged: (value) {
                              search(value);
                            },
                            controller: _searchController,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: actualList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Container(
                                  child: FlatButton(
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  child: Container(
                                                    color: Colors.blue[400],
                                                    width: 35,
                                                    height: 35,
                                                    child: Center(
                                                      child: Text(
                                                        '${actualList[index]['name'][0]}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Container(
                                                  child: Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          index != 0
                                                              ? actualList[index]
                                                                          [
                                                                          'name'] ==
                                                                      actualList[index -
                                                                              1]
                                                                          [
                                                                          'name']
                                                                  ? '${actualList[index]['name']} [copy] '
                                                                  : '${actualList[index]['name']}'
                                                              : '${actualList[index]['name']}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        Text(
                                                          '${actualList[index]['phone']}',
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                          textAlign:
                                                              TextAlign.left,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      print("${actualList[index]['name']} ${actualList[index]['phone']} pressed");
                                      ChatRoom.shared.userCheck(actualList[index]['phone']);

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
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
