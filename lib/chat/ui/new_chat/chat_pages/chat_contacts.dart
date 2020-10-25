import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/db/contacts_db.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import '../../../../tabs.dart';
import 'chat.dart';

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
  void dispose() async {
    super.dispose();
    _searchController.dispose();
    await subscription.cancel();
  }

  StreamSubscription subscription;

  _listen() {
    subscription = ChatRoom.shared.onContactChange.listen((e) {
      print("Contact EVENT ${e.json}");
      var cmd = e.json['cmd'];

      switch (cmd) {
        case "user:check":
          if (!_boolForPrevenceUserCheck) {
          } else {
            if (e.json['data']['chat_id'].toString() != 'false' &&
                e.json['data']['status'].toString() == 'true') {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatName: '${e.json['data']['name']}',
                    chatId: int.parse(e.json['data']['chat_id'].toString()),
                    chatType: 0,
                    avatar: '${e.json['data']['avatar']}',
                  ),
                ),
              ).whenComplete(() {
                ChatRoom.shared.forceGetChat();
              });
            } else if (e.json['data']['status'].toString() == 'true') {
              ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
            }
          }

          break;
        case "chat:create":
          if (e.json["data"]["status"].toString() == "true") {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chatName: '${e.json['data']['chat_name']}',
                  chatId: int.parse(e.json['data']['chat_id'].toString()),
                  chatType: 0,
                ),
              ),
            ).whenComplete(() {
              ChatRoom.shared.forceGetChat();
            });
          } else {
            var name = e.json["data"]["name"];
            var chatID = e.json["data"]["chat_id"];
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chatName: name,
                  chatId: int.parse(
                    chatID.toString(),
                  ),
                ),
              ),
            ).whenComplete(() {
              ChatRoom.shared.forceGetChat();
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
        if (item.name != null && item.phone != null) {
          if (item.name
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.phone
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
        appBar: IndigoAppBarWidget(
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
