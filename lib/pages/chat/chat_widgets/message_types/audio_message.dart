import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/audio/audio_player.dart';

class AudioMessageWidget extends StatefulWidget {
  final String text;
  final String media;

  const AudioMessageWidget({
    Key key,
    this.text,
    @required this.media,
  }) : super(key: key);
  @override
  _AudioMessageWidgetState createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerWidget(url: "$voiceUrl${widget.media}"),
          if (widget.text.toString() != 'null') Text('${widget.text}'),
        ],
      ),
    );
  }
}
