import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indigo24/tabs.dart';
import 'package:indigo24/services/constants.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat/ui/new_chat/chat_models/chat_model.dart';
import 'chat/ui/new_chat/chat_models/hive_names.dart';
import 'chat/ui/new_chat/chat_models/messages.g_model.dart';
import 'chat/ui/new_chat/chat_models/messages_model.dart';
import 'services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;

import 'widgets/alerts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _preferences = await SharedPreferences.getInstance();
  String _languageCode = _preferences.getString('languageCode');
  localization.setLanguage(_languageCode);
  String phone = _preferences.getString('phone');
  String domen2 = _preferences.getString('domen');

  if ('$domen2' == 'null') {
    domen = 'com';
  } else {
    domen = domen2;
  }
  await Hive.initFlutter();
  Hive.registerAdapter(ChatAdapter());
  await Hive.openBox<ChatModel>(HiveBoxes.chats);
  Hive.registerAdapter(MessagesAdapter());
  await Hive.openBox<MessageModel>(HiveBoxes.messages);

  runApp(MyApp(phone: phone, domen: domen));
}

class MyApp extends StatelessWidget {
  final String domen;
  final String phone;

  MyApp({
    Key key,
    this.domen,
    @required this.phone,
  }) : super(key: key);

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
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: '$phone' == 'null' ? IntroPage() : Tabs(),
      ),
    );
  }
}

logOut(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  ChatRoom.shared.channel = null;
  preferences.setString('phone', 'null');
  preferences.setString('pin', 'false');
  Hive.box<MessageModel>(HiveBoxes.messages).clear();
  Hive.box<ChatModel>(HiveBoxes.chats).clear();

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        description: "${localization.sessionIsOver}",
        yesCallBack: () {
          Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => IntroPage(),
            ),
            (r) => false,
          );
        },
      );
    },
  );
}
