import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

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
          "${Localization.language.language}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Container(
          child: ListView.builder(
            itemCount: Localization.languages.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  Material(
                    child: InkWell(
                      onTap: () {
                        Localization.setLanguage(
                            Localization.languages[index].code);
                        setState(
                          () {
                            Localization.language.currentLanguage =
                                '${Localization.languages[index].title}';
                          },
                        );
                      },
                      child: Container(
                        color: whiteColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${Localization.languages[index].title}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: blackPurpleColor,
                              ),
                            ),
                            Localization.language.currentLanguage ==
                                    '${Localization.languages[index].title}'
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
        ),
      ),
    );
  }
}
