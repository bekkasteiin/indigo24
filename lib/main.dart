import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:indigo24/pages/auth/intro.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indigo24/pages/tabs/tabs.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/chat/chat_models/chat_model.dart';
import 'pages/chat/chat_models/hive_names.dart';
import 'pages/chat/chat_models/messages.g_model.dart';
import 'pages/chat/chat_models/messages_model.dart';

import 'package:indigo24/style/colors.dart';
import 'services/shared_preference/shared_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _preferences = await SharedPreferences.getInstance();

  String _languageCode = _preferences.getString(SharedStrings.languageCode);
  Localization.setLanguage(_languageCode);
  String phone = _preferences.getString(SharedStrings.phone);
  String domen2 = _preferences.getString(SharedStrings.domen);

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

class MyApp extends StatefulWidget {
  final String domen;
  final String phone;

  MyApp({
    Key key,
    this.domen,
    @required this.phone,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(
      child: MaterialApp(
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: widget.domen == 'com' ? false : true,
        title: 'Indigo24',
        builder: (context, child) {
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          );
        },
        theme: ThemeData(
          primarySwatch: blueColor,
        ),
        home: '${widget.phone}' != 'null' ? IntroPage() : Tabs(),
      ),
    );
  }
}
