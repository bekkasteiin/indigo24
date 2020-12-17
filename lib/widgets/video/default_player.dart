import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:video_player/video_player.dart';

class DefaultPlayer extends StatefulWidget {
  final url;
  DefaultPlayer({Key key, this.url}) : super(key: key);

  @override
  _DefaultPlayerState createState() => _DefaultPlayerState();
}

class _DefaultPlayerState extends State<DefaultPlayer> {
  FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(widget.url),
        autoPlay: false);
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager.flickControlManager.autoPause();
        } else if (visibility.visibleFraction == 1) {
          // flickManager.flickControlManager.autoResume();
        }
      },
      child: Container(
        child: FlickVideoPlayer(
          flickManager: flickManager,
          flickVideoWithControls: FlickVideoWithControls(
            backgroundColor: blackColor,
            videoFit: BoxFit.contain,
            controls: FlickPortraitControls(
              progressBarSettings: FlickProgressBarSettings(),
            ),
          ),
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            backgroundColor: transparentColor,
            videoFit: BoxFit.contain,
            controls: FlickLandscapeControls(),
          ),
        ),
      ),
    );
  }
}
