import 'package:flutter/material.dart';

indigoAppBar(
  context, {
  Widget title,
  List<Widget> actions,
  double elevation,
  bool withBack,
}) {
  return AppBar(
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    elevation: elevation,
    leading: withBack != null
        ? IconButton(
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
          )
        : SizedBox(height: 0, width: 0),
    title: title,
    actions: actions,
    backgroundColor: Colors.white,
    brightness: Brightness.light,
  );
}
