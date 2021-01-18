import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:indigo24/style/colors.dart';

class TapePhoto extends StatelessWidget {
  const TapePhoto({
    Key key,
    @required Map<String, dynamic> result,
  })  : _result = result,
        super(key: key);

  final Map<String, dynamic> _result;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: ClipRect(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            '$uploadTapes${_result['media']}',
          ),
          backgroundDecoration: BoxDecoration(color: transparentColor),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained,
          enableRotation: false,
        ),
      ),
    );
  }
}
