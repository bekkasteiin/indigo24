import 'package:flutter/material.dart';

class ReceivedMessageWidget extends StatefulWidget {
  final Widget child;

  const ReceivedMessageWidget({Key key, this.child}) : super(key: key);
  @override
  _ReceivedMessageWidgetState createState() => _ReceivedMessageWidgetState();
}

class _ReceivedMessageWidgetState extends State<ReceivedMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-1, 0),
      child: Container(
        child: widget.child,
      ),
    );
  }
}
