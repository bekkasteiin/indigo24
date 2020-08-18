import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/settings/settings_language.dart';
import 'package:indigo24/pages/settings/settings_notifications_main.dart';
import 'package:indigo24/pages/settings/settings_terms.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';

import 'settings_decor.dart';
import 'settings_sound.dart';

class SettingsMainPage extends StatefulWidget {
  @override
  _SettingsMainPageState createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> {
  bool isShowNotificationsSwitched = false;
  bool isPreviewMessageSwitched = false;
  Map<String, dynamic> _settings;

  @override
  void initState() {
    print('this is init of main');
    _listen();
    ChatRoom.shared.getUserSettings();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
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
          title: Text(
            "${localization.settings}",
            style: TextStyle(
              color: blackPurpleColor,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.white,
          brightness: Brightness.light,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      _buildNotifications(),
                      _buildDecor(),
                      _buildLanguage(),
                      _buildTermsOfUse(),

                      // Container(
                      //   margin: EdgeInsets.only(left: 20),
                      //   height: 0.5,
                      //   color: greyColor
                      // ),
                      // Material(
                      //   child: InkWell(
                      //     // onTap: (){
                      //       // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsSoundPage()));
                      //     // },
                      //     child: Container(
                      //       padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                      //       height: 60,
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: <Widget>[
                      //           Text('${localization.notifications}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color:blackPurpleColor),),
                      //           Row(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               // Text('${localization.currentLanguage}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color:blackPurpleColor),),
                      //               Container(
                      //                 margin: EdgeInsets.only(right: 15),
                      //                 child: Image(
                      //                   image: AssetImage(
                      //                     'assets/images/forward.png',
                      //                   ),
                      //                   width: 15,
                      //                   height: 15,
                      //                 ),
                      //               ),
                      //             ]
                      //           )
                      //         ]
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          height: 0.5,
                          color: greyColor),
                      // Container(
                      //   padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: <Widget>[
                      //       Text('${localization.currentLanguage}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color:blackPurpleColor),),
                      //       Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           // Text('${localization.currentLanguage}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color:blackPurpleColor),),
                      //           IconButton(
                      //             icon: Container(
                      //               padding: EdgeInsets.symmetric(vertical: 10),
                      //               child: Image(
                      //                 image: AssetImage(
                      //                   'assets/images/forward.png',
                      //                 ),
                      //               ),
                      //             ),
                      //             onPressed: () {
                      //               Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsSoundPage()));
                      //             },
                      //           ),
                      //         ]
                      //       )
                      //     ]
                      //   ),
                      // ),
                      // Container(
                      //   margin: EdgeInsets.only(left: 20),
                      //   height: 0.5,
                      //   color: greyColor
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _listen() {
    ChatRoom.shared.onSettingsChange.listen((e) {
      print("Settings EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      var message = e.json['data'];

      switch (cmd) {
        case "user:settings:get":
          _settings = message;
          break;

        case "chat:members:delete":
          break;
        default:
          print('Default of settings $message');
      }
    });
  }

  _buildDecor() {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsDecorPage()))
              .whenComplete(() => setState(() {}));
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
          height: 60,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${localization.decor}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackPurpleColor),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Image(
                      image: AssetImage(
                        'assets/images/forward.png',
                      ),
                      width: 15,
                      height: 15,
                    ),
                  ),
                ])
              ]),
        ),
      ),
    );
  }

  _buildLanguage() {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsLanguagePage()))
              .whenComplete(() => setState(() {}));
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
          height: 60,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${localization.language}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackPurpleColor),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    '${localization.currentLanguage}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackPurpleColor),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Image(
                      image: AssetImage(
                        'assets/images/forward.png',
                      ),
                      width: 15,
                      height: 15,
                    ),
                  ),
                ])
              ]),
        ),
      ),
    );
  }

  _buildTermsOfUse() {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsTermsPage()))
              .whenComplete(() => setState(() {}));
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
          height: 60,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${localization.terms}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackPurpleColor),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Image(
                      image: AssetImage(
                        'assets/images/forward.png',
                      ),
                      width: 15,
                      height: 15,
                    ),
                  ),
                ])
              ]),
        ),
      ),
    );
  }

  _buildNotifications() {
    return Material(
      child: InkWell(
        onTap: () {
          ChatRoom.shared.setNotificationSettingsStream();
          print('this is push');
          print(_settings);
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SettingsNotificationsMainPage(settings: _settings)))
              .whenComplete(
            () => setState(
              () {
                ChatRoom.shared.closeNotificationSettingsStream();
                ChatRoom.shared.getUserSettings();
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
          height: 60,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${localization.notifications}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackPurpleColor),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Image(
                      image: AssetImage(
                        'assets/images/forward.png',
                      ),
                      width: 15,
                      height: 15,
                    ),
                  ),
                ])
              ]),
        ),
      ),
    );
  }
}
