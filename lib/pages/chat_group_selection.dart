import 'dart:async';
import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;

class ChatGroupSelection extends StatefulWidget {
  @override
  _ChatGroupSelectionState createState() => _ChatGroupSelectionState();
}

class _ChatGroupSelectionState extends State<ChatGroupSelection> {
  var arrays = [];
  var _saved = List<dynamic>();
  var _savedList = List<dynamic>();

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
      print("GROUP SELECTION EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "user:check":
          if ("${e.json['data']['chat_id']}" != "null" && "${e.json['data']['status']}" == 'true') {
            setState(() {
              _saved.add({"index" : tempIndex, "user_id": e.json['data']['user_id']});
              _savedList.add({"data": e.json, "user_id": e.json['data']['user_id']});
              });

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
          } else{
            _showError(context, 'Данного пользователя нет в системе');
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
          title: Text('Ошибка'),
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
                  "${localization.createGroup}",
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
                        if (_savedList.length > 1) {
                          if (_titleController.text.isNotEmpty) {
                            String user_ids = '';
                            _savedList.forEach((element) {
                              user_ids += element['user_id'] + ',';
                              print(element);
                            });
                            print(user_ids);
                            // ChatRoom.shared.cabinetCreate(_savedList['user_id'].join(','), 1, title: _titleController.text);
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          Container( padding: EdgeInsets.only(top: 10, left: 10),child: Text('${_savedList.length} ${localization.contacts}')),
                          Container(
                            height: _savedList.length == 0  ? 0 : 82,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _savedList.length != null ? _savedList.length : 0,
                              itemBuilder: (BuildContext context, int index) {
                              // print(_savedList[index]);
                              return Stack(
                                children: <Widget>[
                                  Container(
                                    width: 80,
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:BorderRadius.circular(20.0),
                                          child: Container(
                                            color: Color(0xFF0543B8),
                                            width: 35,
                                            height: 35,
                                            child: Center(
                                              child: Text(
                                                '${_savedList[index]['data']['data']['name'][0].toUpperCase()}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Container(
                                          child: Text(
                                            '${_savedList[index]['data']['data']['name']}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        // Text("${_savedList[index][0]}")
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    right: 20,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                             color: Color(0xFF0543B8),
                                            ),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ), 
                                        width: 22, 
                                        height: 22,
                                        child: Center(
                                          child: Center(
                                            child: InkWell(
                                              child: Icon(Icons.close, size: 14, color: Color(0xFF0543B8),),
                                              onTap: (){
                                                setState(() {
                                                   _saved.removeWhere((item) {
                                                    print(item['data']);
                                                    return item['user_id'] == _savedList[index]['user_id'];
                                                  });
                                                  _savedList.removeWhere((item) {
                                                    print(item['data']);
                                                    return item['user_id'] == _savedList[index]['user_id'];
                                                  });
                                                });
                                                
                                              },
                                            ),
                                          ),
                                        )
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
                          child: TextField(
                            decoration: new InputDecoration(
                              hintText: "${localization.chatName}",
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
                                hintText: "${localization.search}",
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
                                    value: _savedList.length == 0  ? false : test(index),
                                    onChanged: (val) {
                                     
                                 
                                      setState(() {
                                        if (val == true) {
                                          tempIndex = index;
                                          ChatRoom.shared.userCheck(actualList[index]['phone']);
                                        } else {
                                          _savedList.removeWhere((item) {
                                            return item['data']['user_id'] == _savedList[index]['data']['user_id'];
                                          });
                                        }
                                      });

                                      _savedList.forEach((element) {
                                        if(element['data']['data']['phone'] == actualList[index]['phone'])
                                          print('this is if $element');
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
  test(index){
    _savedList.forEach((element) {
      if(element['data']['data']['phone'] == actualList[index]['phone']){
        print('this is if $element');
        return true;
      } else {
        return false;
      }
    });
    return false;
  }
}