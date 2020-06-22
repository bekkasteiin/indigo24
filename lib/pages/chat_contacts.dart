import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:indigo24/pages/chat_group_selection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;

import '../main.dart';
var contacts = [];

class ChatContactsPage extends StatefulWidget {
  @override
  _ChatContactsPageState createState() => _ChatContactsPageState();
}


bool firstLoad = true;

class _ChatContactsPageState extends State<ChatContactsPage> {

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
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

  @override
  void initState() {
    super.initState();
    actualList.addAll(contacts);
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
          if (e.json['data']['chat_id'].toString() != 'false' &&
              e.json['data']['status'].toString() == 'true') {
            ChatRoom.shared.setCabinetStream();
            ChatRoom.shared.getMessages('${e.json['data']['chat_id']}');

            print("USER CHECK DATA: ${e.json['data']}");
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      '${e.json['data']['name']}', e.json['data']['chat_id'],
                      memberCount: 2,
                      userIds: e.json['data']['user_id'],
                      avatar: '${e.json['data']['avatar']}',
                      avatarUrl: '${e.json['data']['avatar_url']}')),
            ).whenComplete(() {
              ChatRoom.shared.forceGetChat();
              ChatRoom.shared.closeCabinetStream();
            });
          } else if (e.json['data']['status'].toString() == 'true') {
            ChatRoom.shared.setCabinetStream();
            ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
          }
          break;
        case "chat:create":
          print("CHAT CREATE ${e.json['data']}");
          if (e.json["data"]["status"].toString() == "true") {
            ChatRoom.shared.setCabinetStream();
            ChatRoom.shared.getMessages('${e.json['data']['chat_id']}');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      '${e.json['data']['chat_name']}',
                      e.json['data']['chat_id'],
                      memberCount: 2,
                      userIds: e.json['data']['user_id'])),
            ).whenComplete(() {
              ChatRoom.shared.forceGetChat();
              ChatRoom.shared.closeCabinetStream();
            });
          } else {
            ChatRoom.shared.setCabinetStream();
            var name = e.json["data"]["name"];
            var chatID = e.json["data"]["chat_id"];
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
            ).whenComplete(() {
              ChatRoom.shared.forceGetChat();
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


  Future getCashedContacts() async{
    setState(() {
      actualList.addAll(contacts);
    });
    return contacts;
  }

  TextEditingController _searchController = TextEditingController();

  var actualList = List<dynamic>();

  void search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      contacts.forEach((item) {
        if (item['name'].toLowerCase().contains(query.toLowerCase()) || item['phone'].toLowerCase().contains(query.toLowerCase())) {
          matches.add(item);
        } 
      });
      setState(() {
        actualList.clear();
        actualList.addAll(matches);
      });
      if(actualList.isEmpty){
        setState(() {
          actualList.clear();
          // actualList.addAll(contacts);
        });
      }
      return;
    } else {
      setState(() {
        actualList.clear();
        actualList.addAll(contacts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
      child: Scaffold(
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
                  "${localization.contacts}",
                  style: TextStyle(
                    color: Color(0xFF001D52),
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Container(
                      child: Image(
                        image: AssetImage(
                          'assets/images/refresh.png',
                        ),
                      ),
                    ),
                    iconSize: 30,
                    color: Color(0xFF001D52),
                    onPressed: () {
                      print('update contacts');
                      setState((){
                        getContacts();
                      });
                    },
                  )
                ],
                backgroundColor: Colors.white,
              ),
              body: SafeArea(
                    child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 10.0, right: 10, bottom: 0),
                            child: TextField(
                              decoration: new InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFF001D52),
                                ),
                                hintText: "${localization.search}",
                                fillColor: Color(0xFF001D52),
                              ),
                              onChanged: (value) {
                                search(value);
                              },
                              controller: _searchController,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: actualList != null ? actualList.length : 0,
                              itemBuilder: (BuildContext context, int index) {
                                if('${user.phone}' == '+${actualList[index]['phone']}')
                                  return Center();
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
                                                        BorderRadius.circular(20.0),
                                                    child: Container(
                                                      color: Colors.blue[400],
                                                      width: 35,
                                                      height: 35,
                                                      child: Center(
                                                        child: Text(
                                                          '${actualList[index]['name'][0]}',
                                                          overflow:
                                                              TextOverflow.ellipsis,
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
                                                                ? actualList[index][
                                                                            'name'] ==
                                                                        actualList[
                                                                                index -
                                                                                    1]
                                                                            ['name']
                                                                    ? '${actualList[index]['name']} | Другой номер'
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
                      ),
                  )
                  ),
    );
      
  }
}
