import 'package:flutter/material.dart';

class LinkMessageWidget extends StatefulWidget {
  final String text;

  const LinkMessageWidget({Key key, this.text}) : super(key: key);
  @override
  _LinkMessageWidgetState createState() => _LinkMessageWidgetState();
}

class _LinkMessageWidgetState extends State<LinkMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('${widget.text}'),
    );
  }
}
