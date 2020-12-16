import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/video_player_widget.dart';

class VideoMessageWidget extends StatefulWidget {
  final String text;
  final String media;

  const VideoMessageWidget({
    Key key,
    this.text,
    @required this.media,
  }) : super(key: key);

  @override
  _VideoMessageWidgetState createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VideoPlayerWidget("$videoUrl${widget.media}", "network"),
          widget.text != 'null' ? Text('${widget.text}') : Center(),
        ],
      ),
    );
  }
}
