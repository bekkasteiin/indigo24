import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/video/flick_multi_manager.dart';
import 'package:indigo24/widgets/video/flick_multi_player.dart';

class TapeVideo extends StatelessWidget {
  const TapeVideo({
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
    return new FlickMultiPlayer(
      url: "$uploadTapes${_result['media']}",
      flickMultiManager: _flickMultiManager,
      image: _result['frame'] != null
          ? _result['frame']
          : '${avatarUrl}noAvatar.png',
    );
  }
}
