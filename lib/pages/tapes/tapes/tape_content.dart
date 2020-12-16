import 'package:flutter/material.dart';
import 'package:indigo24/widgets/video/flick_multi_manager.dart';

import 'tape_photo.dart';
import 'tape_video.dart';

class TapeContent extends StatelessWidget {
  const TapeContent({
    Key key,
    @required Map<String, dynamic> result,
    @required FlickMultiManager flickMultiManager,
  })  : _result = result,
        _flickMultiManager = flickMultiManager,
        super(key: key);

  final Map<String, dynamic> _result;
  final FlickMultiManager _flickMultiManager;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      child: Center(
        child: (_result['media'].toString().endsWith("MOV") ||
                _result['media'].toString().endsWith("mov") ||
                _result['media'].toString().endsWith("mp4") ||
                _result['media'].toString().endsWith("mpeg") ||
                _result['media'].toString().endsWith("avi"))
            ? TapeVideo(result: _result, flickMultiManager: _flickMultiManager)
            : TapePhoto(result: _result),
      ),
    );
  }
}
