import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';

class CustomDialog extends StatelessWidget {
  final String title, description;
  final Function yesCallBack;
  final Function noCallBack;

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;

  CustomDialog({
    this.title,
    @required this.description,
    @required this.yesCallBack,
    this.noCallBack,
  });

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
        child: dialogContent(context),
      ),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: padding + 24,
                  bottom: padding,
                  left: padding,
                  right: padding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    title != null
                        ? Text(
                            title,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Container(),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, color: blackPurpleColor),
                    ),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: blackPurpleColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(padding),
                    bottomRight: Radius.circular(padding),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        onPressed: yesCallBack,
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              "OK".toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    noCallBack == null
                        ? SizedBox(height: 0, width: 0)
                        : Container(width: 1, height: 50, color: Colors.white),
                    noCallBack == null
                        ? SizedBox(height: 0, width: 0)
                        : Expanded(
                            child: FlatButton(
                              onPressed: noCallBack,
                              child: Container(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    "${localization.no}".toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
