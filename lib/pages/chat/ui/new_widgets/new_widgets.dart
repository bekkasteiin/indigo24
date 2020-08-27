import 'package:flutter/material.dart';

indigoAppBar(context, {Widget title, List<Widget> actions}) {
  return AppBar(
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
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
    title: title,
    actions: actions,
    backgroundColor: Colors.white,
    brightness: Brightness.light,
  );
}
