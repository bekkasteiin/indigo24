import 'package:flutter/material.dart';

class SendedMessageWidget extends StatefulWidget {
  final Widget child;

  const SendedMessageWidget({Key key, this.child}) : super(key: key);
  @override
  _SendedMessageWidgetState createState() => _SendedMessageWidgetState();
}

class _SendedMessageWidgetState extends State<SendedMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(1, 0),
      child: Container(
        child: widget.child,
      ),
    );
  }
}
