import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/settings/settings_sound.dart';
import 'package:indigo24/services/localization.dart' as localization;

class SettingsLanguagePage extends StatefulWidget {
  @override
  _SettingsLanguagePageState createState() => _SettingsLanguagePageState();
}

class _SettingsLanguagePageState extends State<SettingsLanguagePage> {
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
             Navigator.of(context).pop(true);
          },
        ),
        title: Text(
          "${localization.language}",
          style: TextStyle(
              color: Color(0xFF001D52), fontWeight: FontWeight.w400),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: localization.languages.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                Material(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        localization.currentLanguage = '${localization.languages[index]['title']}';
                      });
                      localization.setLanguage(localization.languages[index]['code']);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${localization.languages[index]['title']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF001D52)),),
                          ]
                        ),
                      ),
                    ),
                  ),
                  Container(
                  margin: EdgeInsets.only(left: 20),
                  height: 0.5,
                  color: Color(0xFF7D8E9B)
                ),
              ],
            );
          },
        ),
      )
    );
  }
}