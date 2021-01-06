import 'package:flutter/material.dart';

class IndigoBottomTab extends StatelessWidget {
  final String path;
  final String text;
  const IndigoBottomTab({
    Key key,
    @required this.path,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      iconMargin: EdgeInsets.only(bottom: 5),
      icon: Image(
        image: AssetImage(path),
        width: 30,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
