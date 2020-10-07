import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

class SettingsLanguagePage extends StatefulWidget {
  @override
  _SettingsLanguagePageState createState() => _SettingsLanguagePageState();
}

class _SettingsLanguagePageState extends State<SettingsLanguagePage> {
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
          "${localization.language}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                      localization
                          .setLanguage(localization.languages[index]['code']);
                      setState(() {
                        localization.currentLanguage =
                            '${localization.languages[index]['title']}';
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  color: greyColor,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
