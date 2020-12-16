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
      icon: Image(
        image: AssetImage(path),
        width: 20,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
