import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool _initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (_initialized != controller.value.initialized) {
      _initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
