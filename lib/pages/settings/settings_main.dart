import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/settings/settings_sound.dart';
import 'package:indigo24/services/localization.dart' as localization;

class SettingsMainPage extends StatefulWidget {
  @override
  _SettingsMainPageState createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> {
  bool isShowNotificationsSwitched = false;
  bool isPreviewMessageSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          style: TextStyle(
              color: Color(0xFF001D52), fontWeight: FontWeight.w400),
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
                padding: EdgeInsets.only(top:20, left: 20, right: 20, bottom: 10),
                child: Text('${localization.chatNotifications}', style: TextStyle(color: Color(0xFF787878), fontWeight: FontWeight.w600)),
              ),
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget> [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 0.5,
                      color: Color(0xFF7D8E9B)
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${localization.showNotifications}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                          CupertinoSwitch(
                            trackColor: Color(0xFFB7C0CE),
                            activeColor: Color(0xFF0543B8),
                            value: isShowNotificationsSwitched,
                            onChanged: (value){
                              setState(() {
                                isShowNotificationsSwitched = value;
                              });
                            },
                          ),
                        ]
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 0.5,
                      color: Color(0xFF7D8E9B)
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${localization.messagePreview}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                          CupertinoSwitch(
                            trackColor: Color(0xFFB7C0CE),
                            activeColor: Color(0xFF0543B8),
                            value: isPreviewMessageSwitched,
                            onChanged: (value){
                              setState(() {
                                isPreviewMessageSwitched = value;
                              });
                            },
                          ),
                        ]
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 0.5,
                      color: Color(0xFF7D8E9B)
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${localization.sound}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text('${localization.sound}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsSoundPage()));
                                },
                              ),
                            ]
                          )
                        ]
                      ),
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
      )
      );
  }
}