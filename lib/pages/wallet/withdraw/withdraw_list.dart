import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/pages/wallet/withdraw/withdraw.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';

class WithdrawListPage extends StatefulWidget {
  @override
  _WithdrawListPageState createState() => _WithdrawListPageState();
}

class _WithdrawListPageState extends State<WithdrawListPage> {
  Api _api;
  List _withdrawList;
  bool _isLoaded;

  @override
  void initState() {
    _isLoaded = false;
    _withdrawList = [];
    _api = Api();
    _api.getWithdraws().then((withdrawResult) {
      setState(() {
        _isLoaded = true;
        _withdrawList = withdrawResult;
      });
    });
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
          "${Localization.language.withdraw}",
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: _mainScreen(context),
    );
  }

  Widget _mainScreen(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _isLoaded
          ? Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: ListView.builder(
                    itemCount: _withdrawList.length,
                    shrinkWrap: false,
                    itemBuilder: (BuildContext context, int index) {
                      return _withdrawElement(context, _withdrawList[index]);
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Container _withdrawElement(BuildContext context, dynamic provider) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
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
        height: 40,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WithdrawPage(provider)),
            );
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 35,
                  height: 40,
                  margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: '$logos${provider['logo']}',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Container(width: 10),
                Text(
                  '${provider['title']}',
                  style: TextStyle(fontSize: 14, color: blackPurpleColor),
                ),
              ],
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
}
