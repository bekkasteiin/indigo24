import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

import 'indigo_square_widget.dart';

class IndigoAuthTitle extends StatelessWidget {
  final String title;
  const IndigoAuthTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IndigoSquare(),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 18,
          ),
        )
      ],
    );
  }
}
