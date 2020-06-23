import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/settings/settings_language.dart';
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
  void initState() {
    print('this is init of main');
    super.initState();
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
                color: Colors.white,
                child: Column(
                  children: <Widget> [
                    Material(
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsLanguagePage())).whenComplete(() => setState((){}));
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('${localization.language}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${localization.currentLanguage}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
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
                                ]
                              )
                            ]
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(left: 20),
                    //   height: 0.5,
                    //   color: Color(0xFF7D8E9B)
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
                    //           Text('${localization.notifications}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                    //           Row(
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //               // Text('${localization.currentLanguage}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
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
                      color: Color(0xFF7D8E9B)
                    ),
                    // Container(
                    //   padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: <Widget>[
                    //       Text('${localization.currentLanguage}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                    //       Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           // Text('${localization.currentLanguage}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
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
                    //   color: Color(0xFF7D8E9B)
                    // ),
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