import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/profile/settings/settings_language.dart';
import 'package:indigo24/pages/profile/settings/settings_notifications_main.dart';
import 'package:indigo24/pages/profile/settings/settings_sound.dart';
import 'package:indigo24/pages/profile/settings/settings_terms.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'settings_decor.dart';

class SettingsMainPage extends StatefulWidget {
  @override
  _SettingsMainPageState createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> {
  Map<String, dynamic> _settings;

  @override
  void initState() {
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
        appBar: IndigoAppBarWidget(
          title: Text(
            "${Localization.language.settings}",
            style: TextStyle(
              color: blackPurpleColor,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: whiteColor,
                  child: Column(
                    children: <Widget>[
                      _settingsRow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SettingsNotificationsMainPage(
                                      settings: _settings),
                            ),
                          ).whenComplete(
                            () => setState(
                              () {
                                ChatRoom.shared.getUserSettings();
                              },
                            ),
                          );
                        },
                        title: Localization.language.notifications,
                      ),
                      _settingsRow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsDecorPage(),
                            ),
                          ).whenComplete(
                            () => setState(() {}),
                          );
                        },
                        title: Localization.language.decor,
                      ),
                      _settingsRow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsLanguagePage(),
                            ),
                          ).whenComplete(
                            () => setState(() {}),
                          );
                        },
                        title: Localization.language.language,
                        subtext: Localization.language.currentLanguage,
                      ),
                      _settingsRow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsTermsPage(),
                            ),
                          ).whenComplete(
                            () => setState(() {}),
                          );
                        },
                        title: Localization.language.terms,
                      ),
                      _settingsRow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsSoundPage(),
                            ),
                          ).whenComplete(
                            () => setState(() {}),
                          );
                        },
                        title: Localization.language.sound,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _listen() {
    ChatRoom.shared.settingsStream.listen((e) {
      print("Settings EVENT");
      var cmd = e.json['cmd'];
      var message = e.json['data'];

      switch (cmd) {
        case "user:settings:get":
          _settings = message;
          break;
        default:
          print('Default of settings $message');
      }
    });
  }

  _settingsRow({
    @required Function onTap,
    @required String title,
    String subtext,
  }) {
    return Column(
      children: [
        Material(
          color: whiteColor,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackPurpleColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (subtext != null)
                        Text(
                          subtext,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: greyColor,
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Image(
                          image: AssetImage(
                            'assets/images/forward.png',
                          ),
                          width: 15,
                          height: 15,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Divider(
            color: darkPrimaryColor,
            height: 0.56,
          ),
        ),
      ],
    );
  }
}
