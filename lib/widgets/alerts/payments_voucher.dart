import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/pages/wallet/payments/payments_history/payment_history_model.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class PaymentVoucher extends StatelessWidget {
  final PaymentHistoryModel paymentHistoryModel;
  final Function buttonCallBack;

  PaymentVoucher({
    this.paymentHistoryModel,
    this.buttonCallBack,
  });

  static const double padding = 16.0;

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(padding),
        ),
        elevation: 0.0,
        backgroundColor: transparentColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: padding,
                        left: padding,
                        right: padding,
                      ),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(padding),
                          topRight: Radius.circular(padding),
                        ),
                      ),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  alignment: Alignment.topCenter,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          logos + paymentHistoryModel.logo,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    paymentHistoryModel.title,
                                    style: TextStyle(color: blackPurpleColor),
                                  ),
                                )
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Localization.language.amount,
                                      style: TextStyle(color: greyColor),
                                    ),
                                    Text(
                                      paymentHistoryModel.amount
                                              .toStringAsFixed(2) +
                                          ' ' +
                                          'KZT',
                                      style: TextStyle(
                                        color: blackPurpleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      Localization.language.commission,
                                      style: TextStyle(color: greyColor),
                                    ),
                                    Text(
                                      0.toString() + ' ' + 'KZT',
                                      style: TextStyle(
                                        color: blackPurpleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(),
                            _vouchetTitle(
                              title: Localization.language.service,
                              content: paymentHistoryModel.title,
                            ),
                            _voucherInfo(
                              leftWidget: Localization.language.date,
                              rigthWidget: paymentHistoryModel.data,
                            ),
                            _voucherInfo(
                              leftWidget: Localization.language.name,
                              rigthWidget: user.name,
                            ),
                            _voucherInfo(
                              leftWidget: Localization.language.payFrom,
                              rigthWidget: user.phone,
                            ),
                            _voucherInfo(
                              leftWidget: Localization.language.destination,
                              rigthWidget: paymentHistoryModel.account,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: identifyColor(
                            int.tryParse(paymentHistoryModel.status)),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(padding),
                          bottomRight: Radius.circular(padding),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: padding / 2,
                        ),
                        child: Center(
                          child: Text(
                            identifyStatus(
                                int.tryParse(paymentHistoryModel.status)),
                            style: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: padding,
                  horizontal: padding * 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Column(
                    //   children: [
                    //     CircleAvatar(
                    //       radius: 30,
                    //       backgroundColor: whiteColor,
                    //       child: IconButton(
                    //         padding: EdgeInsets.zero,
                    //         icon: Container(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: <Widget>[
                    //               Container(
                    //                 child: Image.asset(
                    //                   '${assetsPath}repeat.png',
                    //                   width: 20,
                    //                   height: 20,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         onPressed: buttonCallBack,
                    //       ),
                    //     ),
                    //     FittedBox(
                    //       child: Text(
                    //         Localization.language.repeat,
                    //         style: TextStyle(
                    //           color: whiteColor,
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: whiteColor,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: Image.asset(
                                      '${assetsPath}share.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _screenshotController
                                  .capture()
                                  .then((File image) async {
                                final documentDirectory =
                                    (await getApplicationDocumentsDirectory())
                                        .path;

                                File imgFile =
                                    new File('$documentDirectory/flutter.png');

                                image.copy(imgFile.path);
                                final RenderBox box =
                                    context.findRenderObject();
                                print(documentDirectory);
                                Navigator.pop(context);
                                Share.shareFiles(
                                    ['$documentDirectory/flutter.png'],
                                    sharePositionOrigin:
                                        box.localToGlobal(Offset.zero) &
                                            box.size);
                              }).catchError((onError) {
                                print(onError);
                              });
                            },
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            Localization.language.share,
                            style: TextStyle(
                              color: whiteColor,
                            ),
                          ),
                        )
                      ],
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

  String identifyStatus(int status) {
    switch (status) {
      case 0:
        return Localization.language.newPayment;
        break;
      case 1:
        return Localization.language.newPayment;
        break;
      case 2:
        return Localization.language.error;
        break;
      case 3:
        return Localization.language.pending;
        break;
      case 4:
        return Localization.language.success;
        break;
      default:
        return Localization.language.httpError;
    }
  }

  Color identifyColor(int status) {
    switch (status) {
      case 0:
        return pendingColor;
        break;
      case 1:
        return pendingColor;
        break;
      case 2:
        return errorColor;
        break;
      case 3:
        return pendingColor;
        break;
      case 4:
        return succesColor;
        break;
      default:
        return greyColor;
    }
  }

  Column _vouchetTitle({@required String title, @required String content}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: greyColor,
                    ),
                  ),
                  Text(
                    content,
                    style: TextStyle(
                      color: blackPurpleColor,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Divider(),
      ],
    );
  }

  Padding _voucherInfo({
    @required String leftWidget,
    @required String rigthWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              leftWidget,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: greyColor,
              ),
            ),
          ),
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 5,
            child: Text(
              rigthWidget,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: blackPurpleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
