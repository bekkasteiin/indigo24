import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/chat/ui/new_chat/chat_pages/chat_page_view_test.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

class SettingsTermsPage extends StatefulWidget {
  @override
  _SettingsTermsPageState createState() => _SettingsTermsPageState();
}

class _SettingsTermsPageState extends State<SettingsTermsPage> {
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
          localization.terms,
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(left: 20),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black26,
            //           blurRadius: 10.0,
            //           spreadRadius: -2,
            //           offset: Offset(0.0, 0.0),
            //         )
            //       ],
            //     ),
            //     child: ButtonTheme(
            //       minWidth: MediaQuery.of(context).size.width * 0.42,
            //       height: 50,
            //       child: RaisedButton(
            //         onPressed: () async {
            //           if (await canLaunch(
            //               'https://indigo24.com/security.html')) {
            //             await launch(
            //               'https://indigo24.com/security.html',
            //               forceSafariVC: false,
            //               forceWebView: false,
            //               headers: <String, String>{
            //                 'my_header_key': 'my_header_value'
            //               },
            //             );
            //           } else {
            //             throw 'Could not launch https://indigo24.com/security.html';
            //           }
            //         },
            //         child: FittedBox(
            //           fit: BoxFit.fitWidth,
            //           child: Text(
            //             "${localization.privacyPolicy}",
            //             style: TextStyle(
            //               color: Colors.grey[700],
            //             ),
            //           ),
            //         ),
            //         color: whiteColor,
            //         textColor: whiteColor,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(
            //             10.0,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Container(
              color: whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    child: Text(
                      '${localization.terms.toUpperCase()}',
                      style: TextStyle(
                        color: brightGreyColor2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 5,
                    ),
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
                            Text(
                              "${localization.terms}.pdf",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: blackPurpleColor),
                            ),
                            Flexible(
                              child: Text(
                                "381.0 KB",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: greyColor),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 10,
                      top: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFViewer(
                                  'assets/terms.pdf',
                                  text: localization.terms,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${localization.open}',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
