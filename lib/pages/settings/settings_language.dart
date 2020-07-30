import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';

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
            style:
                TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
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
                      onTap: () {
                        setState(() {
                          localization.currentLanguage =
                              '${localization.languages[index]['title']}';
                        });
                        localization
                            .setLanguage(localization.languages[index]['code']);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 10),
                        height: 60,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${localization.languages[index]['title']}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: blackPurpleColor),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 20),
                      height: 0.5,
                      color: greyColor),
                ],
              );
            },
          ),
        ));
  }
}
