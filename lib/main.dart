import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:indigo24/pages/chat_list.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/pages/wallet.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/test_timer.dart';

import 'package:indigo24/services/user.dart' as user;
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/chats_db.dart';
import 'db/chats_model.dart';
import 'pages/profile.dart';
import 'pages/tapes.dart';
import 'services/api.dart';
import 'services/my_connectivity.dart';
import 'services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;

// void main() {
//   runApp(MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String languageCode = preferences.getString('languageCode');
  localization.setLanguage(languageCode);
  var phone = preferences.getString('phone');
  var unique = preferences.getString('unique');

  var customerID = preferences.getString('customerID');

  print(phone);
  print(unique);
  print(customerID);
  Api api = Api();
  bool authenticated = false;


  await api.checkUnique(unique, customerID).then((r) async {
    if (r['success'] != null) {
      authenticated = r['success'].toString() == 'true';
    } else if (r['result'] != null) {
      print('this is else if ${r['result']}');
      authenticated = r['result']['success'].toString() == 'true';
    }
  });

  runApp(MyApp(phone: phone, authenticated: authenticated));
}

final tabPageKey = new GlobalKey<_TabsState>();

class MyApp extends StatelessWidget {
  
  MyApp({
    Key key,
    @required this.phone,
    this.authenticated,
  }) : super(key: key);
  


  bool authenticated;
  String phone;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Indigo24',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:
            (phone == 'null' || authenticated == false) ? IntroPage() : Tabs(key: tabPageKey),
      ),
    );
  }
}

class Tabs extends StatefulWidget {
  const Tabs({Key key}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController tabController;
  var api = Api();
  MyConnectivity _connectivity = MyConnectivity.instance;
  Map _source = {ConnectivityResult.none: false};

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  var chatsDB = ChatsDB();
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
    return user.id;
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<void> _handleNotification (Map<dynamic, dynamic> message, bool dialog) async {
    var m = message['data'] ?? message;

    _init();

    ChatRoom.shared.getMessages(m['chat_id']);
    goToChat("${m['user_name']}", "${m['chat_id']}",
        memberCount: "${m['type']}" == "0" ? 2 : 3,
        avatar: "${m['avatar']}",
        userIds: "${m['user_id']}");
  }

  
  @override
  void initState() {
    _firebaseMessaging.getToken().then((value) async { 
      print("MY FCM TOKEN $value");
      await api.updateFCM(value, user.id, user.unique);
    });

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

    tabController = new TabController(length: 4, vsync: this);

    setUser().then((result) async {
      print("result: $result");
      print('user: ${user.id}');
      print('user: ${user.name}');
      print('user: ${user.balance}');

      _connectivity.initialise();
      _connectivity.myStream.listen((source) {
        setState(() => _source = source);
        print("Connectivity result $source");
        switch (source.keys.toList()[0]) {
          case ConnectivityResult.none:
            print("NO INTERNET");
            ChatRoom.shared.closeConnection();
            ChatRoom.shared.closeStream();
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
    if (initIsCalling == 1) {
      ChatRoom.shared.connect();
      ChatRoom.shared.setStream();
      _connect();
      ChatRoom.shared.init();
      setState(() {
        initIsCalling += 1;
      });
    }
  }

  _connect() async {
    // ChatRoom.shared.listen();
    ChatRoom.shared.onChange.listen((e) async {
      print("LISTENING EVENT");
      var cmd = e.json["cmd"];
      // print(e.json);
      switch (cmd) {
        case 'message:create':
          
          inAppPush(e.json["data"]);
          break;
        case 'chats:get':
          setState(() {
            // chatsPage += 1;
            myList = e.json['data'].toList();
            chatsModel = myList.map((i) => ChatsModel.fromJson(i)).toList();
          });
          break;
        default:
          print("default in main");
          break;
      }

      // if (chatsPage == 1) {
      //   setState(() {
      //     chatsPage += 1;
      //     myList = e.json['data'].toList();
      //     chatsModel = myList.map((i) => ChatsModel.fromJson(i)).toList();
      //   });
      // } else {
      //   print(
      //       '____________________________________________________________$chatsPage');
      //   // setState(() {
      //   //   chatsPage += 1;
      //   //   myList.addAll(e.json['data'].toList());
      //   // });
      // }
      // await chatsDB.insertChats(chatsModel);
    });
  }

  inAppPush(m) {
    showOverlayNotification((context) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: SafeArea(
          child: ListTile(
            onTap: () {
              OverlaySupportEntry.of(context).dismiss();
              ChatRoom.shared.getMessages(m['chat_id']);
              goToChat("${m['user_name']}", "${m['chat_id']}",
                  memberCount: "${m['type']}" == "0" ? 2 : 3,
                  avatar: "${m['avatar']}",
                  userIds: "${m['user_id']}");
            },
            leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child: ClipOval(
                    child: CachedNetworkImage(
                  imageUrl: "https://media.indigo24.com/avatars/noAvatar.png",
                ))),
            title: Text("${m['user_name']}"),
            subtitle: Text("${m["text"]}"),
            trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  OverlaySupportEntry.of(context).dismiss();
                }),
          ),
        ),
      );
    }, duration: Duration(milliseconds: 4000));
  }

  goToChat(name, chatID, {memberCount, userIds, avatar, avatarUrl}) {
    ChatRoom.shared.setCabinetStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatPage(
                name,
                chatID,
                memberCount: memberCount,
                userIds: userIds,
                avatar: avatar,
                avatarUrl: avatarUrl,
              )),
    ).whenComplete(() {
      ChatRoom.shared.forceGetChat();
      ChatRoom.shared.closeCabinetStream();
    });
  }

  Future _getChats() async {
    Future<List<ChatsModel>> chats = chatsDB.getAllChats();
    chats.then((value) {
      // print('       ');
      // print(value);
      // print('       ');
      setState(() {
        dbChats.addAll(value);
      });
      // print("DB CHATS IN GET $dbChats");
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light) // Or Brightness.dark
        );
    return Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            // ChatsListPage(),
            Developing(),
            UserProfilePage(),
            TapesPage(),
            WalletTab(),
          ],
          controller: tabController,
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
                  controller: tabController,
                  unselectedLabelColor: Color(0xff001D52),
                  labelColor: Color(0xff0543B8),
                  tabs: [
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/chat.png"),
                        width: 20,
                      ),
                      child: Text("${localization.chat}",
                          style: TextStyle(fontSize: 12)),
                    ),
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/profile.png"),
                        width: 20,
                      ),
                      child: Text("${localization.profile}",
                          style: TextStyle(fontSize: 12)),
                    ),
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/tape.png"),
                        width: 20,
                      ),
                      child: Text("${localization.tape}",
                          style: TextStyle(fontSize: 12)),
                    ),
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/wallet.png"),
                        width: 20,
                      ),
                      child: Text("${localization.wallet}",
                          style: TextStyle(fontSize: 12)),
                    )
                  ]),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}


logOut(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('phone', 'null');
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => IntroPage(),
        ),
        (r) => false,
    );
    },
  );
  AlertDialog alert = AlertDialog(
    title: Text("Ошибка"),
    content: Text('test'),
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


class Developing extends StatelessWidget {
  String string = '${localization.chats}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          string,
          style: TextStyle(color: Color(0xFF001D52)),
        ),
        brightness: Brightness.light,
      ),
      body: Center(
        child: Image.asset('assets/developing.gif'),
      ),
    );
  }
}