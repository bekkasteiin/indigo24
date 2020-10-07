import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';

class StickerMessage extends StatefulWidget {
  final String sticker;

  const StickerMessage({
    Key key,
    @required this.sticker,
  }) : super(key: key);
  @override
  _StickerMessageState createState() => _StickerMessageState();
}

class _StickerMessageState extends State<StickerMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.width * 0.3,
      child: CachedNetworkImage(
        imageUrl: '$stickerUrl${widget.sticker}',
      ),
    );
  }
}
