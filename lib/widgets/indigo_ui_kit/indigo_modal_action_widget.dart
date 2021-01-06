import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

class IndigoModalActionWidget extends StatelessWidget {
  const IndigoModalActionWidget({
    this.onPressed,
    this.title,
    this.isDefault = true,
    Key key,
  }) : super(key: key);

  final Function onPressed;
  final String title;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Theme(
        data: ThemeData(),
        child: FlatButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDefault ? blackPurpleColor : errorColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
