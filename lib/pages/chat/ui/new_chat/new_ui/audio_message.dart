import 'package:flutter/material.dart';

import '../../../chat_page_view_test.dart';

class AudioMessageWidget extends StatefulWidget {
  final String text;
  final String mediaUrl; // TODO fix
  final String media;

  const AudioMessageWidget({
    Key key,
    this.text,
    @required this.media,
    @required this.mediaUrl,
  }) : super(key: key);
  @override
  _AudioMessageWidgetState createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  @override
  Widget build(BuildContext context) {
    print("${widget.mediaUrl}l${widget.media}"); // TODO change it
    return Container(child: AudioMessage("${widget.mediaUrl}l${widget.media}"));
  }
}
