import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class DateMessageWidget extends StatelessWidget {
  final String text;
  const DateMessageWidget({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: whiteColor.withOpacity(0.5),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Center(
        child: Text(
          '$text',
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 12,
            color: greyColor2,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
