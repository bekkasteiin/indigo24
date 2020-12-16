import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

class SettingsNotificationsMainPage extends StatefulWidget {
  final Map<String, dynamic> settings;

  const SettingsNotificationsMainPage({Key key, this.settings})
      : super(key: key);

  @override
  _SettingsNotificationsMainPageState createState() =>
      _SettingsNotificationsMainPageState();
}

class _SettingsNotificationsMainPageState
    extends State<SettingsNotificationsMainPage> {
  bool _isHideNotificationsSwitched;
  @override
  void initState() {
    super.initState();
    _isHideNotificationsSwitched =
        widget.settings['settings']['chat_all_mute'].toString() == '1'
            ? true
            : false;
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
          '${localization.notifications}',
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: Text(
                  '${localization.chatNotifications.toUpperCase()}',
                  style: TextStyle(
                    color: brightGreyColor2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 0,
                        top: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${localization.hideNotifications}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: blackPurpleColor,
                            ),
                          ),
                          CupertinoSwitch(
                            trackColor: brightGreyColor3,
                            activeColor: primaryColor,
                            value: _isHideNotificationsSwitched,
                            onChanged: (value) {
                              setState(() {
                                _isHideNotificationsSwitched = value;
                                int boolean = value ? 1 : 0;
                                ChatRoom.shared.setUserSettings(boolean);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
