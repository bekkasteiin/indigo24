import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class IndigoSquare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      decoration: BoxDecoration(
          color: primaryColor, borderRadius: BorderRadius.circular(5)),
      height: 20,
    );
  }
}
