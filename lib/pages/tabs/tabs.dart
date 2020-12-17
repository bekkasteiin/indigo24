import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat/chat_pages/chat.dart';
import 'package:indigo24/pages/chat/chat_pages/chat_contacts.dart';
import 'package:indigo24/pages/chat/chat_pages/chats.dart';
import 'package:indigo24/pages/profile/profile.dart';
import 'package:indigo24/pages/tapes/tapes/tapes.dart';
import 'package:indigo24/pages/wallet/wallet.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/message_type_helper.dart';
import 'package:indigo24/services/helpers/user_helper.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/pin/pin_code.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../db/contact.dart';
import '../../db/contacts_db.dart';
import '../../services/my_connectivity.dart';
import 'indigo_bottom_nav.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

List<MyContact> myContacts = [];
bool closeMainChat = false;
bool isInAppPushActive = false;
String _formatPhone(String phone) {
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

getContactsTemplate(context) async {
  return await getContacts(context).then((getContactsResult) {
    var result = getContactsResult is List ? false : !getContactsResult;

    for (int i = 0; i < getContactsResult.length; i++) {
      ChatRoom.shared.userCheck(getContactsResult[i]['phone']);
    }

    if (result) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            description: localization.allowContacts,
            yesCallBack: () {
              Navigator.pop(context);
              AppSettings.openAppSettings();
            },
            noCallBack: () {
              Navigator.pop(context);
            },
          );
        },
      );
    }
  });
}

getContacts(context) async {
  try {
    contacts.clear();
    if (await Permission.contacts.request().isGranted) {
      Iterable<Contact> phonebook =
          await ContactsService.getContacts(withThumbnails: false);
      if (phonebook != null) {
        phonebook.forEach((el) {
          if (el.displayName != null) {
            el.phones.forEach((phone) {
              if (!contacts.contains(_formatPhone(phone.value))) {
                phone.value = _formatPhone(phone.value);
                if (contacts.every((user) => user['phone'] != phone.value)) {
                  contacts.add({
                    'name': el.displayName,
                    'phone': phone.value,
                    'label': phone.label,
                  });
                }
              }
            });
          }
        });
      }
      return contacts.toSet().toList();
    } else {
      return false;
    }
  } catch (_) {
    print(_);
    return "disconnect";
  }
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  Api api = Api();
  MyConnectivity _connectivity = MyConnectivity.instance;

  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  bool _isSharedVideo = false;

  ContactsDB _contactsDB = ContactsDB();

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  var _tempPasscode;

  share() async {
    await _contactsDB.getAll().then((value) {
      myContacts = value;
    });

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        setState(() {
          print(
              'path of thumbnail: ${value[0].thumbnail}   ${value[0].type == SharedMediaType.VIDEO} ');
          if (value[0].type == SharedMediaType.VIDEO) _isSharedVideo = true;
          print("Shared:" + (value?.map((f) => f.path)?.join(",") ?? ""));
          _sharedFiles = value;
        });
        if (_sharedFiles != null) shareModal();
      },
      onError: (err) {
        print("getIntentDataStream error: $err");
      },
    );

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
      if (_sharedFiles != null) shareModal(); // TESTING
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        print("Shared:" + (value ?? ""));
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {});
    });
  }

  Future<void> _handleNotification(Map<dynamic, dynamic> message) async {
    var _m = message['data'] ?? message;

    ChatRoom.shared.checkUserOnline("${_m['user_id']}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatName: "${_m['chat_name']}",
          chatId: int.parse("${_m['chat_id']}"),
          chatType: int.parse("${_m['chat_type']}"),
          avatar: "${_m['avatar']}",
        ),
      ),
    ).whenComplete(() {
      ChatRoom.shared.forceGetChat();
    });
  }

  _onPasscodeEntered(String enteredPasscode) {
    if (user.pin == 'waiting' && _tempPasscode == enteredPasscode) {
      api.createPin(enteredPasscode);
      Future.delayed(const Duration(milliseconds: 250), () {
        Navigator.pop(context);
      });
    }
    if ('${user.pin}'.toString() == 'waiting' &&
        _tempPasscode != enteredPasscode) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            description: localization.incorrectPin,
            yesCallBack: () {
              Navigator.pop(context);
            },
          );
        },
      );
    }
    if ('${user.pin}'.toString() == 'false') {
      user.pin = 'waiting';
      _tempPasscode = enteredPasscode;
    }

    bool isValid = '${user.pin}' == enteredPasscode;
    if (isValid) {
      Future.delayed(const Duration(milliseconds: 250), () {
        _verificationNotifier.add(isValid);
        Navigator.pop(context);
      });
    } else {
      _verificationNotifier.add(isValid);
    }
  }

  _showLockScreen(BuildContext context, String title, {bool withPin}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          title: title,
          withPin: withPin,
          passwordEnteredCallback: _onPasscodeEntered,
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: milkWhiteColor,
          cancelCallback: _onPasscodeCancelled,
        ),
      ),
    );
  }

  _onPasscodeCancelled() {
    if ('${user.pin}' == 'false') {
      exit(0);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Tabs()),
        (r) => false,
      );
    }
  }

  permissionForPush() async {
    await Permission.notification.request();
  }

  permissions() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    permissionForPush();
  }

  pushPermission() async {
    if (!await Permission.notification.isGranted) {
      PermissionStatus status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
  }

  getUserSettings() {
    ChatRoom.shared.getUserSettings();
  }

  @override
  void initState() {
    api.getConfig();
    permissions();
    pushPermission();
    share();
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    // var fcmTokenStream = _firebaseMessaging.onTokenRefresh;
    // fcmTokenStream.listen((token) {
    //   if (user.id.toString() != null.toString() &&
    //       user.unique.toString() != null.toString() &&
    //       user.phone.toString() != null.toString()) {
    //     api.updateFCM(token);
    //   }
    // });

    Timer.run(() {
      '${user.pin}' == 'false'
          ? _showLockScreen(
              context,
              '${localization.createPin}',
              withPin: false,
            )
          : Text('');
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {
        _handleNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _handleNotification(message);
      },
    );

    _tabController = TabController(length: 4, vsync: this);
    UserHelper userHelper = UserHelper();
    userHelper.setUser().then((result) async {
      _init();
      _connectivity.initialise();
      _connectivity.myStream.listen((source) {
        switch (source.keys.toList()[0]) {
          case ConnectivityResult.none:
            print("NO INTERNET");
            ChatRoom.shared.closeConnection();
            break;
          default:
            print('default connect');
            _init();
            break;
        }
      });
      getContactsTemplate(context);
      setState(() {});
    });
    super.initState();
  }

  _init() {
    ChatRoom.shared.connect(context);
    _listen();
    ChatRoom.shared.init();
    getUserSettings();
  }

  inAppPush(m) {
    print('_________________In App Push $m');
    if (closeMainChat) {
    } else {
      if (!isInAppPushActive) {
        isInAppPushActive = true;
        Future.delayed(Duration(seconds: 4)).then((value) {
          isInAppPushActive = false;
        });
        if (user.settings['settings']['chat_all_mute'].toString() == '1') {
          // check user muted all of chats or not
        } else {
          if (m['mute'].toString() == '1') {
          } else {
            ChatRoom.shared.inSound();
            showOverlayNotification((context) {
              MessageTypeHelper messageType = MessageTypeHelper();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: SafeArea(
                  child: ListTile(
                    onTap: () {
                      OverlaySupportEntry.of(context).dismiss();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => Tabs(),
                        ),
                        (r) => false,
                      );
                    },
                    leading: SizedBox.fromSize(
                      size: Size(40, 40),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: "${avatarUrl}noAvatar.png",
                        ),
                      ),
                    ),
                    title: Text("${m['chat_name']}"),
                    subtitle: Text(
                      m['attachments'] == null
                          ? "${m["text"]}"
                          : messageType.identifyType(m['type']),
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context).dismiss();
                        }),
                  ),
                ),
              );
            }, duration: Duration(seconds: 4));
          }
        }
      }
    }
  }

  _listen() async {
    ChatRoom.shared.mainStream.listen((e) async {
      var cmd = e.json["cmd"];
      switch (cmd) {
        case 'message:create':
          var senderId = e.json["data"]['user_id'].toString();
          var userId = user.id.toString();
          if (senderId != userId) {
            inAppPush(e.json["data"]);
          }
          break;
        case 'user:check':
          var data = e.json["data"];
          if (data['status'].toString() == 'true') {
            MyContact contact = MyContact(
              phone: data['phone'],
              id: int.parse(data['user_id'].toString()),
              avatar: data['avatar'],
              name: data['name'],
              chatId: int.tryParse(data['chat_id'].toString()),
              online: data['online'],
            );
            await _contactsDB.updateOrInsert(contact);
          }
          break;
        default:
          print("default in main $cmd");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          TestChatsListPage(),
          UserProfilePage(),
          TapesPage(),
          WalletTab(),
        ],
        controller: _tabController,
      ),
      bottomNavigationBar: IndigoBottomNav(tabController: _tabController),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  shareModal() {
    showCupertinoModalPopup(
        context: context,
        semanticsDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return CupertinoActionSheet(
              title: Container(
                padding: EdgeInsets.all(10),
                child: Material(
                  color: transparentColor,
                  child: Row(
                    children: [
                      _sharedFiles == null
                          ? Container()
                          : _sharedFiles == null || _sharedFiles.isEmpty
                              ? Container()
                              : Image.file(
                                  File(_isSharedVideo
                                      ? _sharedFiles[0].thumbnail
                                      : _sharedFiles[0].path),
                                  fit: BoxFit.cover,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  height:
                                      MediaQuery.of(context).size.width * 0.2,
                                ),
                      Container(width: 10),
                      Flexible(child: TextField())
                    ],
                  ),
                ),
              ),
              message: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                color: transparentColor,
                child: Stack(
                  children: [
                    isUploading
                        ? Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: CircularPercentIndicator(
                                    radius: 120.0,
                                    lineWidth: 13.0,
                                    animation: false,
                                    percent: uploadPercent,
                                    progressColor: primaryColor,
                                    backgroundColor: blackColor,
                                    center: Text(
                                      percent,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blackColor,
                                          fontSize: 20.0),
                                    ),
                                    footer: Text(
                                      "Загрузка",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: whiteColor,
                                          fontSize: 17.0),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Material(
                            color: transparentColor,
                            child: ListView.builder(
                              itemCount: myContacts.length,
                              itemBuilder: (BuildContext context, int i) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        "$avatarUrl${myContacts[i].avatar}"),
                                  ),
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${myContacts[i].name}"),
                                      Text("${myContacts[i].phone}")
                                    ],
                                  ),
                                  onTap: () {
                                    if (_sharedFiles != null &&
                                        myContacts[i].chatId != null)
                                      sendMedia(
                                        _sharedFiles[0].path,
                                        myContacts[i].chatId,
                                        setState,
                                      );
                                  },
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('${localization.cancel}'),
                onPressed: () {
                  Navigator.pop(context);
                  _sharedFiles.clear();
                  _isSharedVideo = false;
                },
              ),
            );
          });
        });
  }

  sendMedia(path, chatId, StateSetter setState) {
    var type = _isSharedVideo ? 4 : 1;
    uploadMedia(path, type, setState).then((r) async {
      if (r["status"]) {
        var a = [
          _isSharedVideo
              ? {
                  "filename": "${r["file_name"]}",
                }
              : {
                  "filename": "${r["file_name"]}",
                  "r_filename": "${r["resize_file_name"]}"
                }
        ];
        var mediaType = _isSharedVideo ? "video" : "image";
        ChatRoom.shared.sendMessage('$chatId', "$mediaType",
            type: type, attachments: jsonDecode(jsonEncode(a)));
        _sharedFiles.clear();
        _isSharedVideo = false;
        Navigator.pop(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              description: r["message"],
              yesCallBack: () {
                Navigator.pop(context);
              },
            );
          },
        );
      }
    });
  }

  Response response;
  BaseOptions options = BaseOptions(
    baseUrl: "$baseUrl",
    connectTimeout: 25000,
    receiveTimeout: 3000,
  );

  Dio dio;
  var percent = "0 %";
  double uploadPercent = 0.0;
  bool isUploading = false;

  uploadMedia(_path, type, StateSetter setState) async {
    dio = new Dio(options);
    try {
      FormData formData = FormData.fromMap({
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "file": await MultipartFile.fromFile(_path),
        "type": type
      });

      response = await dio.post(
        "$mediaChat",
        data: formData,
        onSendProgress: (int sent, int total) {
          String p = (sent / total * 100).toStringAsFixed(2);

          setState(() {
            isUploading = true;
            uploadPercent = sent / total;
            percent = "$p %";
          });
        },
        onReceiveProgress: (count, total) {
          setState(() {
            isUploading = false;
            uploadPercent = 0.0;
            percent = "0 %";
          });
        },
      );

      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
      } else {}
      return e.response.data;
    }
  }
}
