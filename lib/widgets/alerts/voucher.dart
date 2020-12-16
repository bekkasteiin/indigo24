import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/models/transfer_model.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/user.dart' as user;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class Voucher extends StatelessWidget {
  final TransferModel transferModel;
  final Function buttonCallBack;

  Voucher({
    this.transferModel,
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
        backgroundColor: Colors.transparent,
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
                                      imageUrl: avatarUrl +
                                          transferModel.avatar
                                              .replaceAll('AxB', '200x200'),
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    localization.transfer +
                                        ' ' +
                                        localization.toIndigo24Client,
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
                                      localization.amount,
                                      style: TextStyle(color: greyColor),
                                    ),
                                    Text(
                                      transferModel.amount.toString() +
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
                                      localization.commission,
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
                              title: localization.youReceived,
                              content: transferModel.name,
                            ),
                            if (transferModel.comment?.isNotEmpty != null)
                              _vouchetTitle(
                                title: localization.comments,
                                content: transferModel.comment,
                              ),
                            _voucherInfo(
                              leftWidget: localization.date,
                              rigthWidget: transferModel.data,
                            ),
                            _voucherInfo(
                              leftWidget: localization.name,
                              rigthWidget: transferModel.from,
                            ),
                            _voucherInfo(
                              leftWidget: localization.payFrom,
                              rigthWidget: transferModel.type == 'in'
                                  ? '+' + transferModel.phone
                                  : user.phone,
                            ),
                            _voucherInfo(
                              leftWidget: localization.destination,
                              rigthWidget: transferModel.type == 'out'
                                  ? '+' + transferModel.phone
                                  : user.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: succesColor,
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
                            localization.success,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                                      '${transferModel.type}' == 'in'
                                          ? 'assets/images/replyTransfer.png'
                                          : 'assets/images/repeat.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onPressed: buttonCallBack,
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            '${transferModel.type == 'in' ? localization.reply : localization.repeat}',
                            style: TextStyle(
                              color: whiteColor,
                            ),
                          ),
                        )
                      ],
                    ),
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
                                      'assets/images/share.png',
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
                                    (await getExternalStorageDirectory()).path;
                                File imgFile =
                                    new File('$documentDirectory/flutter.png');
                                image.copy(imgFile.path);
                                final RenderBox box =
                                    context.findRenderObject();
                                print(documentDirectory);
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
                            localization.share,
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
