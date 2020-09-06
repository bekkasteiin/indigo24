import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indigo24/services/localization.dart' as localization;

class TextMessageWidget extends StatefulWidget {
  // final String text;
  final dynamic text;

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
        children: [
          '${widget.text['forward_data']}' != 'null'
              ? Text(
                  '${localization.forwardFrom} ${json.decode(widget.text['forward_data'])['user_name']}')
              : SizedBox(
                  height: 0,
                  width: 0,
                ),
          Text('${widget.text['text']}')
        ],
      ),
    );
  }
}
