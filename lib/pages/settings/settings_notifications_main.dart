import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/settings/settings_sound.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';

class SettingsNotificationsMainPage extends StatefulWidget {
  @override
  _SettingsNotificationsMainPageState createState() =>
      _SettingsNotificationsMainPageState();
}

class _SettingsNotificationsMainPageState
    extends State<SettingsNotificationsMainPage> {
  bool isShowNotificationsSwitched = false;
  bool isPreviewMessageSwitched = false;
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
            "${localization.notifications}",
            style:
                TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
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
                  padding:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                  child: Text('${localization.chatNotifications}',
                      style: TextStyle(
                          color: darkGreyColor2, fontWeight: FontWeight.w600)),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          height: 0.5,
                          color: greyColor),
                      Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${localization.showNotifications}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: blackPurpleColor),
                              ),
                              CupertinoSwitch(
                                trackColor: brightGreyColor3,
                                activeColor: primaryColor,
                                value: isShowNotificationsSwitched,
                                onChanged: (value) {
                                  setState(() {
                                    isShowNotificationsSwitched = value;
                                  });
                                },
                              ),
                            ]),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          height: 0.5,
                          color: greyColor),
                      Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${localization.messagePreview}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: blackPurpleColor),
                              ),
                              CupertinoSwitch(
                                trackColor: brightGreyColor3,
                                activeColor: primaryColor,
                                value: isPreviewMessageSwitched,
                                onChanged: (value) {
                                  setState(() {
                                    isPreviewMessageSwitched = value;
                                  });
                                },
                              ),
                            ]),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          height: 0.5,
                          color: greyColor),
                      Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${localization.sound}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: blackPurpleColor),
                              ),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                // Text('${localization.sound}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color:blackPurpleColor),),
                                IconButton(
                                  icon: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Image(
                                      image: AssetImage(
                                        'assets/images/back.png',
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingsSoundPage()));
                                  },
                                ),
                              ])
                            ]),
                      ),
                      Text('hi'),
                      Text('hi'),
                      Text('hi'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
