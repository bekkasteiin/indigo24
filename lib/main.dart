import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/db/chats_model.dart';
import 'package:indigo24/db/contact.dart';
import 'package:indigo24/db/contacts_db.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_contacts.dart';
import 'package:indigo24/pages/chat/chat_list.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/pages/tapes/tapes.dart';
import 'package:indigo24/pages/wallet/wallet.dart';
import 'package:indigo24/services/helper.dart';

import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/widgets/circle.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/keyboard.dart';
import 'package:indigo24/widgets/pin_code.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/chats_db.dart';
import 'pages/chat/ui/new_chat/chats_list.dart';
import 'pages/profile/profile.dart';
import 'services/api.dart';
import 'services/my_connectivity.dart';
import 'services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;

import 'style/colors.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
bool isInAppPushActive = false;
bool closeMainChat = false;
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

permissionForPush() async {
  await Permission.notification.request();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _preferences = await SharedPreferences.getInstance();
  String _languageCode = _preferences.getString('languageCode');
  localization.setLanguage(_languageCode);
  var phone = _preferences.getString('phone');
  var unique = _preferences.getString('unique');
  var customerID = _preferences.getString('customerID');
  String domen2 = _preferences.getString('domen');
  if ('$domen2' == 'null') {
    domen = 'com';
  } else {
    domen = domen2;
  }
  print(domen);
  print('phone: $phone');
  print('unuque: $unique');
  print('customerID: $customerID');

  //   await ContactsService.addContact(Contact(
  //       displayName: "Name $i",
  //       givenName: 'Givenname $i',
  //       middleName: 'Middlename $i',
  //       phones: [
  //         Item(label: 'home', value: '${87020000000 + i}')
  //       ])); // To Add Contacts

  runApp(MyApp(phone: phone, domen: domen));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({
    Key key,
    this.domen,
    @required this.phone,
  }) : super(key: key);
  String domen;
  bool authenticated;
  String phone;
  String tempString = '';
  TextEditingController sumController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: domen == 'com' ? false : true,
        title: 'Indigo24',
        builder: (context, child) {
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        },
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: phone.toString() == 'null' ? IntroPage() : Tabs(),
      ),
    );
  }
}

inAppPush(m) {
  print('_________________In App Push $m');
  if (closeMainChat) {
  } else {
    if (!isInAppPushActive) {
      // Check if inAppPush is alreadyExist
      isInAppPushActive = true;
      Future.delayed(Duration(seconds: 4)).then((value) {
        isInAppPushActive = false;
      });
      if (user.settings['settings']['chat_all_mute'].toString() == '1') {
        // check user muted all of chats or not
      } else {
        print(m['mute'].toString() == '1');
        if (m['mute'].toString() == '1') {
        } else {
          ChatRoom.shared.inSound();
          showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: SafeArea(
                child: ListTile(
                  onTap: () {
                    OverlaySupportEntry.of(context).dismiss();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Tabs()),
                        (r) => false);
                    ChatRoom.shared.getMessages(m['chat_id']);
                    _goToChat(
                      "${m['chat_name']}",
                      "${m['chat_id']}",
                      context,
                      memberCount: "${m['type']}" == "0" ? 2 : 3,
                      chatType: "${m['chat_type']}",
                      avatar: "${m['avatar']}",
                      userIds: "${m['user_id']}",
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
                        : _identifyType(m['type']),
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

_goToChat(name, chatID, context,
    {chatType, memberCount, userIds, avatar, avatarUrl}) {
  // ChatRoom.shared.setChatStream();
  ChatRoom.shared.checkUserOnline(userIds);
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ChatPage(
              chatName: name,
              chatId: chatID,
              chatType: chatType,
              userIds: userIds,
              avatar: avatar,
              avatarUrl: avatarUrl,
            )),
  ).whenComplete(() {
    // this is bool for check load more is needed or not
    ChatRoom.shared.forceGetChat();
    ChatRoom.shared.closeChatStream();
  });
}

_identifyType(type) {
  // const TEXT_MESSAGE_TYPE = 0;
  // const IMAGE_MESSAGE_TYPE = 1;
  // const DOCUMENT_MESSAGE_TYPE = 2;
  // const VOICE_MESSAGE_TYPE = 3;
  // const VIDEO_MESSAGE_TYPE = 4;
  // const SYSTEM_MESSAGE_TYPE = 7;
  // const SYSTEM_MESSAGE_DIVIDER_TYPE = 8;
  // const GEO_POINT_MESSAGE_TYPE = 9;
  // const REPLY_MESSAGE_TYPE = 10;
  // const MONEY_MESSAGE_TYPE = 11;
  // const LINK_MESSAGE_TYPE = 12;
  // const FORWARD_MESSAGE_TYPE = 13;

  switch ('$type') {
    case '0':
      return '${localization.textMessage}';
      break;
    case '1':
      return '${localization.photo}';
      break;
    case '2':
      return '${localization.document}';
      break;
    case '3':
      return '${localization.voiceMessage}';
      break;
    case '4':
      return '${localization.video}';
      break;
    case '7':
      return '${localization.systemMessage}';
      break;
    // case '8':
    // return 'Дивайдер сообщение';
    // break;
    case '9':
      return '${localization.location}';
      break;
    case '10':
      return '${localization.reply}';
      break;
    case '11':
      return '${localization.money}';
      break;
    case '12':
      return '${localization.link}';
      break;
    case '13':
      return '${localization.forwardedMessage}';
      break;
    default:
      return '${localization.message}';
  }
}

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

List<MyContact> myContacts = [];

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  Api api = Api();
  MyConnectivity _connectivity = MyConnectivity.instance;
  Map _source = {ConnectivityResult.none: false};

  // StreamSubscription<ConnectivityResult> _connectivitySubscription;

  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;
  bool _isSharedVideo = false;
  ChatsDB _chatsDB = ChatsDB();

  ContactsDB _contactsDB = ContactsDB();

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  var _tempPasscode;
  share() async {
    await _contactsDB.getAll().then((value) {
      myContacts = value;
    });

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        print(
            'path of thumbnail: ${value[0].thumbnail}   ${value[0].type == SharedMediaType.VIDEO} ');
        if (value[0].type == SharedMediaType.VIDEO) _isSharedVideo = true;
        print("Shared:" + (value?.map((f) => f.path)?.join(",") ?? ""));
        _sharedFiles = value;
      });
      if (_sharedFiles != null) shareModal();
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        print("app is closed Shared:  ${value == null}" +
            (value?.map((f) => f.path)?.join(",") ?? ""));

        _sharedFiles = value;
      });
      if (_sharedFiles != null) shareModal(); // TESTING
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        print("Shared:" + (value ?? ""));
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
      });
    });
  }

  setUser() async {
    user.id = await SharedPreferencesHelper.getCustomerID();
    user.phone = await SharedPreferencesHelper.getString('phone');
    user.balance = await SharedPreferencesHelper.getString('balance');
    user.balanceInBlock =
        await SharedPreferencesHelper.getString('balanceInBlock');
    user.name = await SharedPreferencesHelper.getString('name');
    user.email = await SharedPreferencesHelper.getString('email');
    user.avatar = await SharedPreferencesHelper.getString('avatar');
    user.unique = await SharedPreferencesHelper.getString('unique');
    user.pin = await SharedPreferencesHelper.getString('pin');
    return user.id;
  }

  Future<void> _handleNotification(
      Map<dynamic, dynamic> message, bool dialog) async {
    var m = message['data'] ?? message;

    _init();

    ChatRoom.shared.getMessages(m['chat_id']);
    _goToChat(
      "${m['chat_name']}",
      "${m['chat_id']}",
      memberCount: "${m['type']}" == "0" ? 2 : 3,
      chatType: "${m['chat_type']}",
      avatar: "${m['avatar']}",
      userIds: "${m['user_id']}",
    );
  }

  _onPasscodeEntered(String enteredPasscode) {
    if (user.pin == 'waiting' && _tempPasscode == enteredPasscode) {
      print('creating');
      api.createPin(enteredPasscode);
      Future.delayed(const Duration(milliseconds: 250), () {
        Navigator.pop(context);
      });
    }
    if ('${user.pin}'.toString() == 'waiting' &&
        _tempPasscode != enteredPasscode) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('${localization.error}'),
            content: Text('${localization.incorrectPin}'),
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
    if ('${user.pin}'.toString() == 'false') {
      user.pin = 'waiting';
      _tempPasscode = enteredPasscode;
      print('first set pin $_tempPasscode');
    }

    bool isValid = '${user.pin}' == enteredPasscode;
    if (isValid) {
      Future.delayed(const Duration(milliseconds: 250), () {
        print(' is really valid ');
        _verificationNotifier.add(isValid);
        Navigator.pop(context);
      });
    } else {
      _verificationNotifier.add(isValid);
    }

    // if (!isValid){
    // return showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return CupertinoAlertDialog(
    //       title: Text('${localization.error}'),
    //       content: Text('${localization.incorrectPin}'),
    //       actions: <Widget>[
    //         CupertinoDialogAction(
    //           child: Text('Ok'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
    // }
  }

  _showLockScreen(BuildContext context, String title,
      {bool withPin,
      bool opaque,
      CircleUIConfig circleUIConfig,
      KeyboardUIConfig keyboardUIConfig,
      Widget cancelButton,
      List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: title,
            withPin: withPin,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: (cancelButton),
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: blackPurpleColor),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: milkWhiteColor,
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
          ),
        ));
  }

  _onPasscodeCancelled() {
    if ('${user.pin}' == 'false') {
      exit(0);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Tabs()), (r) => false);
    }
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

  // initDownloader() async {
  //   await FlutterDownloader.initialize(debug: true);
  // }

  getUserSettings() {
    ChatRoom.shared.getUserSettings();
  }

  @override
  void initState() {
    api.getConfig();
    permissions();
    pushPermission();
    share();

    // initDownloader();
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    var fcmTokenStream = _firebaseMessaging.onTokenRefresh;
    fcmTokenStream.listen((token) {
      if (user.id.toString() != null.toString() &&
          user.unique.toString() != null.toString() &&
          user.phone.toString() != null.toString()) {
        api.updateFCM(token);
      }
    });

    Timer.run(() {
      '${user.pin}' == 'false'
          ? _showLockScreen(context, '${localization.createPin}',
              withPin: false,
              opaque: false,
              cancelButton: Text('${localization.cancel}',
                  style: TextStyle(fontSize: 16, color: blackPurpleColor),
                  semanticsLabel: '${localization.cancel}'))
          : Text('');
    });

    getContactsTemplate(context);

    // _firebaseMessaging.getToken().then((value) async {
    //   print("MY FCM TOKEN $value");
    //   await api.updateFCM(value).then((val) {
    //     print("VALUE VALUE $val");
    //   });
    // });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // _handleNotification(message, true);

        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _handleNotification(message, true);
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _handleNotification(message, true);
        // _navigateToItemDetail(message);
      },
    );

    _tabController = new TabController(length: 4, vsync: this);

    setUser().then((result) async {
      print("result: $result");
      print('user id: ${user.id}');
      print('user name: ${user.name}');
      print('user balance: ${user.balance}');
      _init();
      _connectivity.initialise();
      _connectivity.myStream.listen((source) {
        setState(() => _source = source);
        print("Connectivity result $source");
        switch (source.keys.toList()[0]) {
          case ConnectivityResult.none:
            print("NO INTERNET");
            ChatRoom.shared.closeConnection();
            ChatRoom.shared.closeChatsListStream();
            setState(() {
              initIsCalling = 1;
            });
            break;
          default:
            print("DEFAULT ");
            _init();
            // ChatRoom.shared.setStream();
            // _connect();
            // ChatRoom.shared.init();
            break;
        }
      });

      setState(() {});
    });

    super.initState();
  }

  var initIsCalling = 1;

  _init() {
    ChatRoom.shared.connect(context);
    ChatRoom.shared.setChatsListStream();
    _connect();
    ChatRoom.shared.init();
    getUserSettings();
  }

  _connect() async {
    ChatRoom.shared.onMainChange.listen((e) async {
      var cmd = e.json["cmd"];
      // print('CHAT LISTS MAIN LISTENER ${e.json}');
      switch (cmd) {
        case 'message:create':
          print(e.json["data"]);
          var senderId = e.json["data"]['user_id'].toString();
          var userId = user.id.toString();
          print('message create');
          if (senderId != userId) {
            inAppPush(e.json["data"]);
          }
          break;
        case 'user:check':
          var data = e.json["data"];
          print('data is $data');
          if (data['status'].toString() == 'true') {
            MyContact contact = MyContact(
              phone: data['phone'],
              id: int.parse(data['user_id'].toString()),
              avatar: data['avatar'],
              name: data['name'],
              chatId: int.parse(data['chat_id'].toString()),
              online: data['online'],
            );
            await _contactsDB.updateOrInsert(contact);
          }
          break;
        default:
          print("default in main ${e.json}");
          break;
      }
    });
  }

  updateOrInsertChat(ChatsModel chat) async {
    // await chatsDB.deleteAll();
    await _chatsDB.updateOrInsert(chat);
  }

  _goToChat(name, chatID, {chatType, memberCount, userIds, avatar, avatarUrl}) {
    // ChatRoom.shared.setChatStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatName: name,
          chatId: chatID,
          chatType: chatType,
          userIds: userIds,
          avatar: avatar,
          avatarUrl: avatarUrl,
        ),
      ),
    ).whenComplete(() {
      ChatRoom.shared.forceGetChat();
      ChatRoom.shared.closeChatStream();
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
      bottomNavigationBar: SafeArea(
        child: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            padding: EdgeInsets.only(
              top: 5,
              left: 0,
              right: 0,
            ),
            height: 55,
            child: TabBar(
              indicatorPadding: EdgeInsets.all(1),
              labelPadding: EdgeInsets.all(0),
              indicatorWeight: 0.0000000000001,
              controller: _tabController,
              unselectedLabelColor: blackPurpleColor,
              labelColor: primaryColor,
              tabs: [
                Tab(
                  icon: Image(
                    image: AssetImage("assets/images/chat.png"),
                    width: 20,
                  ),
                  child: Text("${localization.chat}",
                      style: TextStyle(fontSize: 12)),
                ),
                Tab(
                  icon: Image(
                    image: AssetImage("assets/images/profile.png"),
                    width: 20,
                  ),
                  child: Text("${localization.profile}",
                      style: TextStyle(fontSize: 12)),
                ),
                Tab(
                  icon: Image(
                    image: AssetImage("assets/images/tape.png"),
                    width: 20,
                  ),
                  child: Text("${localization.tape}",
                      style: TextStyle(fontSize: 12)),
                ),
                Tab(
                  icon: Image(
                    image: AssetImage("assets/images/wallet.png"),
                    width: 20,
                  ),
                  child: Text("${localization.wallet}",
                      style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
        ),
      ),
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
                  color: Colors.transparent,
                  child: new Row(
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
                color: Colors.transparent,
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
                                          color: Colors.black,
                                          fontSize: 20.0),
                                    ),
                                    footer: Text(
                                      "Загрузка",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 17.0),
                                    ),
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: ListView.builder(
                              itemCount: myContacts.length,
                              itemBuilder: (BuildContext context, int i) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        "$avatarUrl${myContacts[i].avatar}"),
                                    // child: Text('${myContacts[i].name[0]}'),
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
                                    print(myContacts[i]);
                                    if (_sharedFiles != null &&
                                        myContacts[i].chatId != null)
                                      sendMedia(_sharedFiles[0].path,
                                          myContacts[i].chatId, setState);
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
      print("RRR $r");
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
        showAlertDialog(context, r["message"]);
        print("error");
      }
    });
  }

  Response response;
  BaseOptions options = new BaseOptions(
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

      print("Uploading media with data ${formData.fields}");
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
          print("$percent");
        },
        onReceiveProgress: (count, total) {
          setState(() {
            isUploading = false;
            uploadPercent = 0.0;
            percent = "0 %";
          });
        },
      );
      print("Getting response from media upload ${response.data}");

      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response);
      } else {
        print("ERROR $e");
        print(e.request.data);
        print(e.message);
      }
      return e.response.data;
    }
  }

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("${localization.error}"),
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
}

dioError(context) async {
  Widget okButton = CupertinoDialogAction(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  CupertinoAlertDialog alert = CupertinoAlertDialog(
    title: Text("${localization.error}"),
    content: Text('${localization.httpError}'),
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

ChatsDB _chatsDB = ChatsDB();

logOut(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  ChatRoom.shared.channel = null;
  // await api.updateFCM('logoutToken');
  preferences.setString('phone', 'null');
  preferences.setString('pin', 'false');
  Widget okButton = CupertinoDialogAction(
    child: Text("OK"),
    onPressed: () async {
      _chatsDB.deleteAll();
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => IntroPage(),
        ),
        (r) => false,
      );
    },
  );
  CupertinoAlertDialog alert = CupertinoAlertDialog(
    title: Text("${localization.error}"),
    content: Text('${localization.sessionIsOver}'),
    actions: [
      okButton,
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class Developing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          localization.chats,
          style: TextStyle(color: blackPurpleColor),
        ),
        brightness: Brightness.light,
      ),
      body: Center(
        child: Image.asset('assets/developing.gif'),
      ),
    );
  }
}
