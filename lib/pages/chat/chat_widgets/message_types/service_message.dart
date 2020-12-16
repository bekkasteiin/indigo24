import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class DeviderMessageWidget extends StatelessWidget {
  final String text;
  const DeviderMessageWidget({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Center(
        child: Text(
          '$text',
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 12, color: darkGreyColor2),
        ),
      ),
    );
  }
}
