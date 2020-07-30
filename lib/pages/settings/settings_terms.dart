import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';

class SettingsTermsPage extends StatefulWidget {
  @override
  _SettingsTermsPageState createState() => _SettingsTermsPageState();
}

class _SettingsTermsPageState extends State<SettingsTermsPage> {
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
            "${localization.terms}",
            style:
                TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.white,
          brightness: Brightness.light,
        ),
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Text(
                '${localization.terms}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: blackPurpleColor),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/pdf.png",
                    width: 50,
                    height: 50,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Terms.pdf",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: blackPurpleColor)),
                      Flexible(
                          child: Text("381.0 KB",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: greyColor))),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () {},
                    child: Text('Скачать на устройство'),
                  ),
                  FlatButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PDFViewer('assets/terms.pdf')));
                      // if (await canLaunch('https://indigo24.com/rules.html')) {
                      //   await launch(
                      //     'https://indigo24.com/rules.html',
                      //     forceSafariVC: false,
                      //     forceWebView: false,
                      //     headers: <String, String>{
                      //       'my_header_key': 'my_header_value'
                      //     },
                      //   );
                      // } else {
                      //   throw 'Could not launch https://indigo24.com/rules.html';
                      // }
                    },
                    child: Text('Открыть'),
                  )
                ],
              ),
            )
          ],
        )));
  }
}
