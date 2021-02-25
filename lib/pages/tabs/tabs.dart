import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indigo24/pages/chat/chat_models/chat_model.dart';
import 'package:indigo24/pages/chat/chat_models/hive_names.dart';
import 'package:indigo24/pages/chat/chat_pages/chat.dart';
import 'package:indigo24/pages/chat/chat_pages/chats/chats.dart';
import 'package:indigo24/pages/chat/chat_pages/chats/chats_element.dart';
import 'package:indigo24/pages/profile/profile.dart';
import 'package:indigo24/pages/tapes/tapes_widgets/tapes.dart';
import 'package:indigo24/pages/wallet/wallet/wallet.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/contacts.dart';
import 'package:indigo24/services/helpers/message_type_helper.dart';
import 'package:indigo24/services/helpers/user_helper.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/pin/pin_code.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:indigo24/services/db/contact/contact_model.dart';
import 'package:indigo24/services/db/contact/contacts_repo.dart';

import '../../services/my_connectivity.dart';
import 'indigo_bottom_nav.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

bool closeMainChat = false;
bool isInAppPushActive = false;

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
      return showIndigoDialog(
        context: context,
        builder: CustomDialog(
          description: Localization.language.incorrectPin,
          yesCallBack: () {
            Navigator.pop(context);
          },
        ),
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

  permissions() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    await Permission.notification.request();
  }

  pushPermission() async {
    if (!await Permission.notification.isGranted) {
      PermissionStatus status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
  }

  @override
  void initState() {
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
      api.checkVersion().then((result) async {
        final PackageInfo _packageInfo = await PackageInfo.fromPlatform();
        String appVersion =
            _packageInfo.version + ':' + _packageInfo.buildNumber;
        print(result);
        print(appVersion);
        if (result == appVersion) {
          if ('${user.pin}' == 'false') print('TODO TURN ON');

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PasscodeScreen(
                title: Localization.language.createPin,
                withPin: false,
                passwordEnteredCallback: _onPasscodeEntered,
                shouldTriggerVerification: _verificationNotifier.stream,
                backgroundColor: milkWhiteColor,
                cancelCallback: _onPasscodeCancelled,
              ),
            ),
          );
        } else {
          logOut(context);
        }
      });
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
      api.getConfig();

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
      IndigoContacts.getContactsTemplate(context);
      setState(() {});
    });

    super.initState();
  }

  _init() {
    ChatRoom.shared.connect(context);
    _listen();
    ChatRoom.shared.init();
    ChatRoom.shared.getUserSettings();
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
            showOverlayNotification(
              (context) {
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
              },
              duration: Duration(seconds: 4),
            );
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
          return CupertinoActionSheet(
            title: Container(
              padding: EdgeInsets.all(5),
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
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.2,
                              ),
                    Container(width: 10),
                    Flexible(
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 6,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: Localization.language.enterMessage,
                          hintStyle: TextStyle(
                            color: greyColor2,
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                      ),
                    )
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
                          child: ValueListenableBuilder(
                            valueListenable:
                                Hive.box<ChatModel>(HiveBoxes.chats)
                                    .listenable(),
                            builder: (context, Box box, widget) {
                              return ListView.builder(
                                itemCount: box.values.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return ChatsElement(
                                    chat: box.values.elementAt(i),
                                    onTap: () {
                                      if (_sharedFiles != null &&
                                          box.values.elementAt(i).chatId !=
                                              null)
                                        sendMedia(
                                          _sharedFiles[0].path,
                                          box.values.elementAt(i).chatId,
                                        );
                                    },
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
              child: Text('${Localization.language.cancel}'),
              onPressed: () {
                Navigator.pop(context);
                _sharedFiles.clear();
                _isSharedVideo = false;
              },
            ),
          );
        });
  }

  sendMedia(path, chatId) {
    var type = _isSharedVideo ? 4 : 1;
    api.uploadMedia(
      path,
      type,
      requestURL: mediaChat,
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
    ).then((r) async {
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
        showIndigoDialog(
          context: context,
          builder: CustomDialog(
            description: r["message"],
            yesCallBack: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    });
  }

  var percent = "0 %";
  double uploadPercent = 0.0;
  bool isUploading = false;
}
