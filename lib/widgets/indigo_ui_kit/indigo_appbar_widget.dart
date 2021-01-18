import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/constants.dart';

class IndigoAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final bool centerTitle;
  final Widget title;
  final Widget leading;
  final Brightness brightness;
  final List<Widget> actions;
  final Color backgroundColor;
  final double elevation;

  const IndigoAppBarWidget({
    Key key,
    this.centerTitle = true,
    this.title,
    this.leading,
    this.brightness = Brightness.light,
    this.actions,
    this.backgroundColor = whiteColor,
    this.elevation,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      leading: leading == null
          ? IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage('${assetsPath}back.png'),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : leading,
      brightness: brightness,
      title: title,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
