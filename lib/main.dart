import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat_list.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/pages/wallet.dart';
import 'package:indigo24/services/helper.dart';

import 'package:indigo24/services/user.dart' as user;
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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var phone = prefs.getString('phone');
  var unique = prefs.getString('unique');
  var customerID = prefs.getString('customerID');
  print(phone);
  print(unique);
  print(customerID);
  Api api = Api();
  
  // await api.checkUnique(unique,customerID).then((r) async {
    
  //   });

  runApp(MyApp(phone: phone));
}

class MyApp extends StatelessWidget {

  const MyApp({
    Key key,
    @required this.phone,
  }) : super(key: key);

  final String phone;




  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: phone == null ? IntroPage() : Tabs(),
    );
  }
}

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;

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

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);

    setUser().then((result) async{
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
      // print(e.json);
      setState(() {
        // chatsPage += 1;
        myList = e.json['data'].toList();
        chatsModel = myList.map((i) => ChatsModel.fromJson(i)).toList();
      });
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
            ChatsListPage(),
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
                  unselectedLabelColor: Color(0xff001D52),
                  labelColor: Color(0xff0543B8),
                  tabs: [
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/chat.png"),
                        width: 20,
                      ),
                      child: Text("${localization.chat}", style: TextStyle(fontSize: 12)),
                    ),
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/profile.png"),
                        width: 20,
                      ),
                      child: Text("${localization.profile}", style: TextStyle(fontSize: 12)),
                    ),
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/tape.png"),
                        width: 20,
                      ),
                      child: Text("${localization.tape}", style: TextStyle(fontSize: 12)),
                    ),
                    new Tab(
                      icon: new Image(
                        image: AssetImage("assets/images/wallet.png"),
                        width: 20,
                      ),
                      child: Text("${localization.wallet}", style: TextStyle(fontSize: 12)),
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
