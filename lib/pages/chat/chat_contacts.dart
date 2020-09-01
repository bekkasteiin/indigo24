import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/db/contacts_db.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_list.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';

var contacts = [];

class ChatContactsPage extends StatefulWidget {
  @override
  _ChatContactsPageState createState() => _ChatContactsPageState();
}

class _ChatContactsPageState extends State<ChatContactsPage> {
  TextEditingController _searchController = TextEditingController();

  List _actualList = List<dynamic>();

  ContactsDB _contactsDB = ContactsDB();

  bool _boolForPrevenceUserCheck = true;

  @override
  void initState() {
    super.initState();
    _actualList.addAll(myContacts);
    ChatRoom.shared.setContactsStream();
    _listen();
    getContacts(context).then((getContactsResult) {
      var result = getContactsResult is List ? false : !getContactsResult;
      if (result) {
        Widget okButton = CupertinoDialogAction(
          child: Text("${localization.openSettings}"),
          onPressed: () {
            Navigator.pop(context);
            AppSettings.openAppSettings();
          },
        );
        CupertinoAlertDialog alert = CupertinoAlertDialog(
          title: Text("${localization.error}"),
          content: Text('${localization.allowContacts}'),
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
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  _listen() {
    ChatRoom.shared.onContactChange.listen((e) {
      print("Contact EVENT ${e.json}");
      var cmd = e.json['cmd'];

      switch (cmd) {
        case "user:check":
          if (!_boolForPrevenceUserCheck) {
          } else {
            if (e.json['data']['chat_id'].toString() != 'false' &&
                e.json['data']['status'].toString() == 'true') {
              ChatRoom.shared.setChatStream();
              ChatRoom.shared.getMessages(e.json['data']['chat_id']);

              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                        '${e.json['data']['name']}', e.json['data']['chat_id'],
                        memberCount: 2,
                        userIds: e.json['data']['user_id'],
                        avatar: '${e.json['data']['avatar']}',
                        chatType: 0,
                        avatarUrl: '${e.json['data']['avatar_url']}')),
              ).whenComplete(() {
                // this is bool for check load more is needed or not
                ChatRoom.shared.forceGetChat();
                ChatRoom.shared.closeChatStream();
              });
            } else if (e.json['data']['status'].toString() == 'true') {
              // print('____________________');
              // print('else if e.jsonDataStatus == true');
              // print({e.json['data']['user_id']});
              // print('____________________');
              ChatRoom.shared.setChatStream();
              ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
            }
          }

          break;
        case "chat:create":
          print("CHAT CREATE ${e.json['data']}");
          if (e.json["data"]["status"].toString() == "true") {
            ChatRoom.shared.setChatStream();
            ChatRoom.shared.getMessages(e.json['data']['chat_id']);
            Navigator.pop(context);
            // print('_________________________________');
            // print('chat contacts user ids ${e.json['data']['user_id']}');
            // print('_________________________________');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      '${e.json['data']['chat_name']}',
                      e.json['data']['chat_id'],
                      memberCount: 2,
                      chatType: 0,
                      userIds: e.json['data']['user_id'])),
            ).whenComplete(() {
              // this is bool for check load more is needed or not
              ChatRoom.shared.forceGetChat();
              ChatRoom.shared.closeChatStream();
            });
          } else {
            ChatRoom.shared.setChatStream();
            var name = e.json["data"]["name"];
            var chatID = e.json["data"]["chat_id"];
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
            ).whenComplete(() {
              ChatRoom.shared.forceGetChat();
              ChatRoom.shared.closeChatStream();
            });
          }
          break;

        default:
      }
    });
  }

  _search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      myContacts.forEach((item) {
        print('${item.name} ${item.phone}');
        if (item.name != null && item.phone != null) {
          if (item.name
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.phone
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
            print('a');
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
        _actualList.addAll(myContacts);
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
              color: blackPurpleColor,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            IconButton(
              icon: Container(
                height: 20,
                width: 20,
                child: Image(
                  image: AssetImage(
                    'assets/images/refresh.png',
                  ),
                ),
              ),
              iconSize: 30,
              color: blackPurpleColor,
              onPressed: () async {
                _boolForPrevenceUserCheck = false;
                print('update contacts');
                await getContactsTemplate(context);
                await _contactsDB.getAll().then((value) {
                  myContacts = value;
                  setState(() {
                    _actualList.clear();
                    _actualList.addAll(value);
                  });
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
              Expanded(
                child: _actualList.isNotEmpty
                    ? ListView.builder(
                        itemCount: _actualList != null ? _actualList.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          if ('${user.phone}' == '+${_actualList[index].phone}')
                            return Center();
                          if (_actualList[index].phone == null &&
                              _actualList[index].name == null)
                            return Container();
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              child: FlatButton(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
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
                                                    '${_actualList[index].name.toString()[0]}',
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
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      index != 0
                                                          ? _actualList[index]
                                                                      .name ==
                                                                  _actualList[
                                                                          index -
                                                                              1]
                                                                      .name
                                                              ? '${_actualList[index].name}'
                                                              : '${_actualList[index].name}'
                                                          : '${_actualList[index].name}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    Text(
                                                      '${_actualList[index].phone}',
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                  _boolForPrevenceUserCheck = true;
                                  ChatRoom.shared
                                      .userCheck(_actualList[index].phone);
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
                      )
                    : Center(
                        child: Text('${localization.emptyContacts}'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
