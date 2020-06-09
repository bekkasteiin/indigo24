import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat_list.dart';

import 'db/chats_db.dart';
import 'db/chats_model.dart';
import 'pages/profile.dart';
import 'pages/tapes.dart';
import 'pages/wallet_tab.dart';
import 'services/my_connectivity.dart';
import 'services/socket.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Tabs(),
    );
  }
}

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin{

  TabController _tabController; 
   
  MyConnectivity _connectivity = MyConnectivity.instance;
  Map _source = {ConnectivityResult.none: false};
  
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  var chatsDB = ChatsDB();

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);


  _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
      switch (source.keys.toList()[0]) {
      case ConnectivityResult.none:
        
        break;
      default:   
        ChatRoom.shared.setStream();
        _connect();
        ChatRoom.shared.init();
        break;
    }
    });
     _getChats();

    super.initState();
  }

  _connect() async {
    ChatRoom.shared.listen();
    ChatRoom.shared.onChange.listen((e) async {
      print("LISTENING EVENT");
      print(e.json);

      setState(() {
        myList = e.json['data'].toList();
        chatsModel = myList.map((i) => ChatsModel.fromJson(i)).toList();   
      });
      // await chatsDB.insertChats(chatsModel);
    });
    
  }
  


  Future _getChats() async {
    Future<List<ChatsModel>> chats = chatsDB.getAllChats();
    chats.then((value) {
      setState(() {
        dbChats.addAll(value);
      });
      print("DB CHATS IN GET $dbChats");
    });
  }


  @override
  Widget build(BuildContext context) {
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
              top: 0,
              left: 0,
              right: 0,
            ),
            height: 45,
          child: TabBar(
            indicatorPadding: EdgeInsets.all(0),            
            labelPadding: EdgeInsets.all(0),
            indicatorWeight: 0.0000000000001,
            controller: _tabController,
            unselectedLabelColor: Color(0xff001D52),
            labelColor: Color(0xff0543B8),
            tabs: [
              new Tab(
                  icon: new Image(image: AssetImage("assets/images/chat.png"), width: 20,),
                  child: Text("Чат", style: TextStyle(fontSize: 12)),
              ),
              new Tab(
                  icon: new Image(image: AssetImage("assets/images/profile.png"), width: 20,),
                  child: Text("Профиль", style: TextStyle(fontSize: 12)),
              ),
              new Tab(
                  icon: new Image(image: AssetImage("assets/images/tape.png"), width: 20,),
                  child: Text("Лента", style: TextStyle(fontSize: 12)),
              ),
              new Tab(
                  icon: new Image(image: AssetImage("assets/images/wallet.png"), width: 20,),
                  child: Text("Кошелек", style: TextStyle(fontSize: 12)),
              )
            ]
          ),
        ),
                ),
      )
    );
  }
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
}

