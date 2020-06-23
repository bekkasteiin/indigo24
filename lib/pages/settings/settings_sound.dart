import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;

class SettingsSoundPage extends StatefulWidget {
  @override
  _SettingsSoundPageState createState() => _SettingsSoundPageState();
}

class _SettingsSoundPageState extends State<SettingsSoundPage> {
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
          "${localization.sound}",
          style: TextStyle(color: Color(0xFF001D52), fontWeight: FontWeight.w400),
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
                  children: <Widget> [
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${localization.showNotifications}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
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
                        ]
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 0.5,
                      color: Color(0xFF7D8E9B)
                    ),
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