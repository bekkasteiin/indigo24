import 'package:flutter/material.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:indigo24/services/user.dart' as user;

import 'identification_info.dart';

class InentificationListPage extends StatefulWidget {
  @override
  _InentificationListPageState createState() => _InentificationListPageState();
}

class _InentificationListPageState extends State<InentificationListPage> {
  final String identificationUrl = "https://indigo24.com/identify.html";
  Api _api = Api();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: IndigoAppBarWidget(
        title: Text(
          "${Localization.language.identification}",
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            if (user.identified != 2 && user.identified == 0)
              Column(
                children: [
                  button(
                    size: size,
                    title: Localization.language.simpleIdentification,
                    type: 2,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            if (user.identified != 2 && user.identified == 0)
              Column(
                children: [
                  button(
                    size: size,
                    title: Localization.language.fullIdentification,
                    type: 1,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            if (user.identified == 2)
              Column(
                children: [
                  button(
                    size: size,
                    title: Localization.language.afterFullIdentification,
                    type: 1,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () async {
                  if (await canLaunch(
                    identificationUrl,
                  )) {
                    await launch(
                      identificationUrl,
                      forceSafariVC: false,
                      forceWebView: false,
                      headers: <String, String>{
                        'my_header_key': 'my_header_value'
                      },
                    );
                  } else {
                    throw 'Could not launch $identificationUrl';
                  }
                },
                child: Container(
                  color: transparentColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.help,
                        color: primaryColor,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "${Localization.language.infoAboutIdentification}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InentificationInfoPage(),
                    ),
                  );
                },
                child: Container(
                  color: transparentColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: primaryColor,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          child: Text(
                            "${Localization.language.infoAboutSimpleIdentification}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  button({
    @required Size size,
    @required String title,
    @required int type,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: blackColor,
            blurRadius: 10.0,
            spreadRadius: -10,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: ButtonTheme(
        height: 70,
        child: RaisedButton(
          onPressed: () async {
            var result = await _api.identification(type);
            print(result);
            print(result['token']);
            if (await canLaunch(
              result['URL'],
            )) {
              await launch(
                result['URL'].toString() +
                    "?token=" +
                    result['token'].toString() +
                    '&customerId=' +
                    user.id,
                forceSafariVC: false,
                forceWebView: false,
              );
            } else {
              showIndigoDialog(
                context: context,
                builder: CustomDialog(
                  description: "${result['message']}",
                  yesCallBack: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '$title'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          color: whiteColor,
          textColor: blackPurpleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
        ),
      ),
    );
  }
}
