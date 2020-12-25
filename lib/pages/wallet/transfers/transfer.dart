import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/wallet/transfers/transfer_draggrable.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/pin/pin_code.dart';

class TransferPage extends StatefulWidget {
  final phone;
  final transferChat;
  const TransferPage({
    this.phone,
    this.transferChat,
  });
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  Api api = Api();
  showAlertDialog(BuildContext context, String type, String message) {
    showIndigoDialog(
      context: context,
      builder: CustomDialog(
        description: "$message",
        yesCallBack: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  final receiverController = TextEditingController();
  final sumController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  bool boolForPreloader = false;
  Color phoneColor;
  Color sumColor;

  @override
  void initState() {
    phoneColor = blackColor;
    sumColor = blackColor;
    if (widget.phone != null) {
      receiverController.text = widget.phone;
      setState(() {
        toName = '';
        toAvatar = '';
      });
      if (receiverController.text.length > 10) {
        api.checkPhoneForSendMoney('${widget.phone}').then((r) {
          if (r['success'].toString() == 'true') {
            setState(() {
              toName = r['name'];
              toAvatar = r['avatar'];
            });
          } else {
            setState(() {
              toName = '${Localization.language.userNotFound}';
              toAvatar = '';
            });
          }
        });
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: whiteColor,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            body: Container(
              height: size.height,
              width: size.width,
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/images/wallet_header.png'),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IndigoAppBarWidget(
                                title: Text(
                                  Localization.language.toIndigo24Client,
                                  textAlign: TextAlign.center,
                                ),
                                leading: IconButton(
                                  icon: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Image(
                                      image: AssetImage(
                                        'assets/images/backWhite.png',
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                elevation: 0,
                                backgroundColor: transparentColor,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 0, right: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 0.6,
                                      margin: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 20,
                                      ),
                                      color: brightGreyColor,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 20, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 15),
                                          Text(
                                            '${Localization.language.walletBalance}',
                                            style: fS14(c: 'FFFFFF'),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                '${user.balance}',
                                                style: fS18(c: 'FFFFFF'),
                                              ),
                                              Image(
                                                image: AssetImage(
                                                    "assets/images/tenge.png"),
                                                height: 12,
                                                width: 12,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        mainPaymentsDetailMobile(),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          color: whiteColor,
                          child: TextField(
                            style: TextStyle(color: greyColor),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: greyColor),
                              hintText: Localization.language.enterMessage,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                              ),
                              fillColor: greyColor,
                            ),
                            controller: _commentController,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _commentButton(
                                  size,
                                  Localization.language.thankYou,
                                  _commentController),
                              _commentButton(
                                  size,
                                  Localization.language.returning,
                                  _commentController),
                              _commentButton(
                                  size,
                                  Localization.language.withLove,
                                  _commentController),
                            ],
                          ),
                        ),
                        transferButton(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  boolForPreloader
                      ? Container(
                          color: whiteColor.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Center()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _commentButton(
      Size size, String comment, TextEditingController controller) {
    return Container(
      height: 30,
      width: size.width * 0.25,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: blackColor,
            blurRadius: 10.0,
            spreadRadius: -10,
          ),
        ],
      ),
      child: RaisedButton(
        onPressed: () async {
          controller.text = comment;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
        child: Container(
          child: FittedBox(
            child: Text(
              '$comment',
              style: TextStyle(
                color: blackPurpleColor,
              ),
            ),
          ),
        ),
        color: whiteColor,
        textColor: blackPurpleColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool checked = false;
  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = '${user.pin}' == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (enteredPasscode == user.pin) {
      Future.delayed(const Duration(milliseconds: 250), () {
        Navigator.pop(context);
        if (receiverController.text.isNotEmpty &&
            sumController.text.isNotEmpty) {
          setState(() {
            boolForPreloader = true;
          });
          api.checkPhoneForSendMoney(receiverController.text).then((result) {
            setState(() {
              boolForPreloader = false;
            });
            if (result['message'] == 'Not authenticated' &&
                result['success'].toString() == 'false') {
              logOut(context);
              return result;
            } else {
              if (result["success"].toString() == 'true') {
                setState(() {
                  boolForPreloader = true;
                });
                api
                    .doTransfer(
                  result["toID"],
                  sumController.text,
                  transferChat: widget.transferChat,
                  comment: _commentController.text,
                )
                    .then((res) {
                  setState(() {
                    boolForPreloader = false;
                  });
                  if (res['success'].toString() == 'false')
                    showIndigoDialog(
                      context: context,
                      builder: CustomDialog(
                        description: '${res['message']}',
                        yesCallBack: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  else {
                    showIndigoDialog(
                      context: context,
                      builder: CustomDialog(
                        description: '${res['message']}',
                        yesCallBack: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                    if (res['transfer_money_chat_token'].toString() != 'null')
                      ChatRoom.shared.sendMoney(
                          res['transfer_money_chat_token'],
                          widget.transferChat);
                    api.getBalance().then((result) {
                      setState(() {});
                    });
                  }
                });
              } else {
                showIndigoDialog(
                  context: context,
                  builder: CustomDialog(
                    description: '${result['message']}',
                    yesCallBack: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              }

              return result;
            }
          });
        } else {
          showIndigoDialog(
            context: context,
            builder: CustomDialog(
              description: '${Localization.language.fillAllFields}',
              yesCallBack: () {
                Navigator.pop(context);
              },
            ),
          );
        }
      });
    }
  }

  _onPasscodeCancelled() {
    Navigator.pop(context);
  }

  _showLockScreen(BuildContext context, String title, {bool withPin}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          title: '$title',
          withPin: withPin,
          passwordEnteredCallback: _onPasscodeEntered,
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: milkWhiteColor,
          cancelCallback: _onPasscodeCancelled,
        ),
      ),
    );
  }

  Container transferButton() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: blackColor,
            blurRadius: 10.0,
            spreadRadius: -10,
            offset: Offset(
              0.0,
              0.0,
            ),
          )
        ],
      ),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (receiverController.text.isNotEmpty) {
              setState(() {
                phoneColor = blackColor;
              });
              if (sumController.text.isNotEmpty) {
                setState(() {
                  sumColor = blackColor;
                });
                _showLockScreen(
                  context,
                  '${Localization.language.enterPin}',
                );
              } else {
                setState(() {
                  sumColor = redColor;
                });
              }
            } else {
              setState(() {
                phoneColor = redColor;
              });
            }
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${Localization.language.transfer}',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
              ),
            ),
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

  String toName = '';
  String toAvatar = '';
  Container mainPaymentsDetailMobile() {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Text(
                              '${Localization.language.reveicerPhone}',
                              style: TextStyle(
                                color: greyColor2,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(25),
                              ],
                              decoration: InputDecoration.collapsed(
                                hintText:
                                    '${Localization.language.phoneNumber}',
                                hintStyle: TextStyle(
                                  color: greyColor2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              controller: receiverController,
                              style: TextStyle(fontSize: 18),
                              onChanged: (value) {
                                setState(() {
                                  toName = '';
                                  toAvatar = '';
                                });
                                if (receiverController.text.length > 10) {
                                  api
                                      .checkPhoneForSendMoney('$value')
                                      .then((r) {
                                    if (r['success'].toString() == 'true') {
                                      setState(() {
                                        toName = r['name'];
                                        toAvatar = r['avatar'];
                                      });
                                    } else {
                                      setState(() {
                                        toName =
                                            '${Localization.language.userNotFound}';
                                        toAvatar = '';
                                      });
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            child: CircleAvatar(
                              radius: 20,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: toAvatar == ''
                                      ? "${avatarUrl}noAvatar.png"
                                      : '$avatarUrl${toAvatar.replaceAll('AxB', '200x200')}',
                                ),
                              ),
                            ),
                            onTap: () async {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              dynamic returnData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TransferContactsDialogPage(),
                                ),
                              );
                              if (returnData != null) {
                                api
                                    .checkPhoneForSendMoney(
                                        '${returnData.phone}')
                                    .then((r) {
                                  if (r['success'].toString() == 'true') {
                                    setState(() {
                                      toName = r['name'];
                                      toAvatar = r['avatar'];
                                    });
                                  } else {
                                    setState(() {
                                      // toName = '${Localization.language.userNotFound}';
                                      toName = '${r['message']}';
                                      toAvatar = '';
                                    });
                                  }
                                });
                                receiverController.text = returnData.phone;
                              }
                            },
                          ),
                          Text(
                            '$toName',
                            textAlign: TextAlign.justify,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 1.0,
                  color: brightGreyColor,
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        '${Localization.language.transferAmount}',
                        style: TextStyle(
                          color: greyColor2,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [],
                        controller: sumController,
                        decoration: InputDecoration.collapsed(
                          hintText: '${Localization.language.amount}',
                          hintStyle: TextStyle(
                            color: greyColor2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                        onChanged: (value) {
                          if (sumController.text[0] == '0') {
                            sumController.clear();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: whiteColor,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _commentButton(size, '1000', sumController),
                _commentButton(size, '5000', sumController),
                _commentButton(size, '20000', sumController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    receiverController.dispose();
    sumController.dispose();
    _commentController.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
