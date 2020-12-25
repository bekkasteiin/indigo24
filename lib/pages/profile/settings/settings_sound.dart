import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSoundPage extends StatefulWidget {
  @override
  _SettingsSoundPageState createState() => _SettingsSoundPageState();
}

class _SettingsSoundPageState extends State<SettingsSoundPage> {
  List<String> sounds = [
    'message_in.mp3',
    'messageIn.mp3',
  ];

  @override
  void initState() {
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
          Localization.language.sound,
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
                    ListView.separated(
                      separatorBuilder: (context, index) => Container(
                          margin: EdgeInsets.only(left: 20),
                          height: 0.5,
                          color: greyColor),
                      shrinkWrap: true,
                      itemCount: sounds.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Material(
                              child: InkWell(
                                onTap: () async {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setString('sound', sounds[index]);
                                  setState(() {
                                    user.sound = sounds[index];
                                  });
                                  ChatRoom.shared.inSound();
                                },
                                child: Container(
                                  color: whiteColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        '${Localization.language.sound} $index',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: blackPurpleColor,
                                        ),
                                      ),
                                      user.sound == sounds[index]
                                          ? Icon(
                                              Icons.done,
                                              color: darkPrimaryColor,
                                            )
                                          : Center()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Divider(
                                color: darkPrimaryColor,
                                height: 0.5,
                              ),
                            ),
                          ],
                        );
                      },
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
