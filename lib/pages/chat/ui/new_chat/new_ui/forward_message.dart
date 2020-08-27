import 'package:flutter/material.dart';

class ForwardMessageWidget extends StatefulWidget {
  final String text;

  const ForwardMessageWidget({Key key, this.text}) : super(key: key);
  @override
  _ForwardMessageWidgetState createState() => _ForwardMessageWidgetState();
}

class _ForwardMessageWidgetState extends State<ForwardMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('${widget.text}'),
    );
  }
}
