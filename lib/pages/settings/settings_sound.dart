import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSoundPage extends StatefulWidget {
  @override
  _SettingsSoundPageState createState() => _SettingsSoundPageState();
}

class _SettingsSoundPageState extends State<SettingsSoundPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> sounds = [
    'message_in.mp3',
    'messageIn.mp3',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${localization.sound}",
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
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    ListView.separated(
                      separatorBuilder: (context, index) => Container(
                        margin: EdgeInsets.only(left: 20),
                        height: 0.5,
                        color: greyColor,
                      ),
                      shrinkWrap: true,
                      itemCount: sounds.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            '${localization.sound} $index',
                          ),
                          tileColor: user.sound == sounds[index]
                              ? greenColor.withOpacity(0.3)
                              : Colors.transparent,
                          onTap: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('sound', sounds[index]);
                            setState(() {
                              user.sound = sounds[index];
                            });
                            ChatRoom.shared.inSound();
                          },
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
