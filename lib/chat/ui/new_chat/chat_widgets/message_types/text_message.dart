import 'package:flutter/material.dart';

class TextMessageWidget extends StatefulWidget {
  final text;

  const TextMessageWidget({Key key, this.text}) : super(key: key);
  @override
  _TextMessageWidgetState createState() => _TextMessageWidgetState();
}

class _TextMessageWidgetState extends State<TextMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.2,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('${widget.text.text}')],
      ),
    );
  }
}
