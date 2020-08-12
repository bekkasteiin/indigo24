import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/socket.dart';

import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/circle.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/keyboard.dart';
import 'package:indigo24/widgets/pin_code.dart';

class TransferContactsDialogPage extends StatefulWidget {
  @override
  TransferContactsDialogPageState createState() =>
      TransferContactsDialogPageState();
}

class TransferContactsDialogPageState
    extends State<TransferContactsDialogPage> {
  TextEditingController _searchController = TextEditingController();

  List actualList = List<dynamic>();

  search(String query) {
    if (query.isNotEmpty) {
      List<dynamic> matches = List<dynamic>();
      myContacts.forEach((item) {
        if (item.name != null && item.phone != null) {
          if (item.name
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item.phone
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
            matches.add(item);
          }
        }
      });
      setState(() {
        actualList = [];
        actualList.addAll(matches);
      });
      return;
    } else {
      setState(() {
        actualList = [];
        actualList.addAll(myContacts);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    actualList.addAll(myContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "${localization.contacts}",
              style: TextStyle(
                color: blackPurpleColor,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            elevation: 0,
            centerTitle: true,
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
                Navigator.pop(context);
              },
            ),
            backgroundColor: whiteColor,
            brightness: Brightness.light,
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10, bottom: 0),
                  child: TextField(
                    decoration: new InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: blackPurpleColor,
                      ),
                      hintText: "${localization.search}",
                      fillColor: blackPurpleColor,
                    ),
                    onChanged: (value) {
                      search(value);
                    },
                    controller: _searchController,
                  ),
                ),
                ListView.builder(
                  itemCount: actualList != null ? actualList.length : 0,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    if (actualList[i].phone == null) return Center();
                    return Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, actualList[i]);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 40,
                          ),
                          child: Row(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
                                child: Image.network(
                                  '${actualList[i].avatar}' == ''
                                      ? '${avatarUrl}noAvatar.png'
                                      : '$avatarUrl${actualList[i].avatar.replaceAll('AxB', '200x200')}',
                                  width: 35,
                                  height: 35,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        '${actualList[i].name}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '${actualList[i].phone}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransferPage extends StatefulWidget {
  final phone;
  final amount;
  final transferChat;
  const TransferPage({this.phone, this.transferChat, this.amount});
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  Api api = Api();

  showAlertDialog(BuildContext context, String type, String message) {
    // set up the button
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(type == '0'
          ? "${localization.attention}"
          : type == '1' ? '${localization.success}' : '${localization.error}'),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final receiverController = TextEditingController();
  final sumController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  bool boolForPreloader = false;

  @override
  void initState() {
    print('${widget.amount}');

    if (widget.phone != null) {
      receiverController.text = widget.phone;
      if (widget.amount != null) {
        sumController.text = widget.amount;
      }
      setState(() {
        toName = '';
        toAvatar = '';
      });
      if (receiverController.text.length > 10) {
        api.checkPhoneForSendMoney('${widget.phone}').then((r) {
          print(r);
          if (r['success'].toString() == 'true') {
            setState(() {
              toName = r['name'];
              toAvatar = r['avatar'];
            });
          } else {
            setState(() {
              toName = '${localization.userNotFound}';
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
      color: Colors.white,
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
                        Stack(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/background_little.png',
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              child: AppBar(
                                centerTitle: true,
                                title: Text("${localization.toIndigo24Client}"),
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
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(top: 45, left: 0, right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 0.6,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    color: brightGreyColor,
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 30, right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 15),
                                        Text(
                                          '${localization.walletBalance}',
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        mainPaymentsDetailMobile(),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          color: Colors.white,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: localization.enterMessage,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(),
                              ),
                              fillColor: Colors.green,
                            ),
                            controller: _commentController,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _commentButton(size, localization.thankYou),
                              _commentButton(size, localization.returning),
                              _commentButton(size, localization.withLove),
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
                      ? Center(child: CircularProgressIndicator())
                      : Center()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _commentButton(Size size, String comment) {
    return Container(
      height: 30,
      width: size.width * 0.25,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -10,
          ),
        ],
      ),
      child: RaisedButton(
        onPressed: () async {
          _commentController.text = comment;
          _commentController.selection = TextSelection.fromPosition(
            TextPosition(offset: _commentController.text.length),
          );
        },
        child: Container(
          child: FittedBox(
            child: Text(
              '$comment',
              style: TextStyle(
                color: blackColor,
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

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
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
          Navigator.pop(context);
        },
      ),
      brightness: Brightness.light,
      title: Text(
        "${localization.toIndigo24Client}",
        style: TextStyle(
          color: blackPurpleColor,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
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
          print('global bool resetted to true');
          setState(() {
            boolForPreloader = true;
          });
          api.checkPhoneForSendMoney(receiverController.text).then((result) {
            print('transfer result $result');
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
                    showAlertDialog(context, '0', res['message']);
                  else {
                    showAlertDialog(context, '1', res['message']);
                    ChatRoom.shared.sendMoney(
                        res['transfer_money_chat_token'], widget.transferChat);
                    api.getBalance().then((result) {
                      setState(() {});
                    });
                  }
                });
              } else {
                showAlertDialog(context, '0', result['message']);
              }

              return result;
            }
          });
        } else {
          showAlertDialog(context, '0', '${localization.fillAllFields}');
        }
      });
    }
  }

  _onPasscodeCancelled() {
    Navigator.pop(context);
  }

  _showLockScreen(BuildContext context, String title,
      {bool withPin,
      bool opaque,
      CircleUIConfig circleUIConfig,
      KeyboardUIConfig keyboardUIConfig,
      Widget cancelButton,
      List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: '$title',
            withPin: withPin,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: blackPurpleColor),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: milkWhiteColor,
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
          ),
        ));
  }

  Container transferButton() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (receiverController.text.isNotEmpty &&
                sumController.text.isNotEmpty) {
              _showLockScreen(context, '${localization.enterPin}',
                  opaque: false,
                  cancelButton: Text('Cancel',
                      style: const TextStyle(
                          fontSize: 16, color: blackPurpleColor),
                      semanticsLabel: 'Cancel'));
            }
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${localization.transfer}',
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
    return Container(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(25),
                        ],
                        decoration: InputDecoration.collapsed(
                          hintText: '${localization.phoneNumber}',
                        ),
                        controller: receiverController,
                        style: TextStyle(fontSize: 20),
                        onChanged: (value) {
                          setState(() {
                            toName = '';
                            toAvatar = '';
                          });
                          if (receiverController.text.length > 10) {
                            api.checkPhoneForSendMoney('$value').then((r) {
                              print(r);
                              if (r['success'].toString() == 'true') {
                                setState(() {
                                  toName = r['name'];
                                  toAvatar = r['avatar'];
                                });
                              } else {
                                setState(() {
                                  toName = '${localization.userNotFound}';
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    child: CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                        child: CachedNetworkImage(
                            imageUrl: toAvatar == ''
                                ? "${avatarUrl}noAvatar.png"
                                : '$avatarUrl${toAvatar.replaceAll('AxB', '200x200')}'),
                      ),
                    ),
                    onTap: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      dynamic returnData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransferContactsDialogPage(),
                        ),
                      );
                      if (returnData != null) {
                        api
                            .checkPhoneForSendMoney('${returnData.phone}')
                            .then((r) {
                          print(r);
                          if (r['success'].toString() == 'true') {
                            setState(() {
                              toName = r['name'];
                              toAvatar = r['avatar'];
                            });
                          } else {
                            setState(() {
                              // toName = '${localization.userNotFound}';
                              toName = '${r['message']}';
                              toAvatar = '';
                            });
                          }
                        });
                        receiverController.text = returnData.phone;
                      }
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text(
                      '$toName',
                      maxLines: 4,
                    ),
                  )
                ],
              ),
            ],
          ),
          Container(
            height: 1.0,
            color: Colors.grey,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    controller: sumController,
                    decoration: InputDecoration.collapsed(
                        hintText: '${localization.amount}'),
                    style: TextStyle(fontSize: 20),
                    onChanged: (value) {
                      if (sumController.text[0] == '0') {
                        sumController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  final amountController = TextEditingController();
}
