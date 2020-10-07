import 'package:flutter/material.dart';

class ForwardMessageWidget extends StatefulWidget {
  final String text;
  final Widget child;

  const ForwardMessageWidget({Key key, this.text, this.child})
      : super(key: key);
  @override
  _ForwardMessageWidgetState createState() => _ForwardMessageWidgetState();
}

class _ForwardMessageWidgetState extends State<ForwardMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}
