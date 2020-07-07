// Color palette for the unthemed pages
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

List<VideoPlayerController> videoPlayers = [];

class Palette {
  static Color primaryColor = Colors.white;
  static Color accentColor = Color(0xff4fc3f7);
  static Color secondaryColor = Colors.black;

  static Color gradientStartColor = accentColor;
  static Color gradientEndColor = Color(0xff6aa8fd);
  static Color errorGradientStartColor = Color(0xffd50000);
  static Color errorGradientEndColor = Color(0xff9b0000);

  static Color primaryTextColorLight = Colors.white;
  static Color secondaryTextColorLight = Colors.white70;
  static Color hintTextColorLight = Colors.white70;

  static Color selfMessageBackgroundColor = Color(0xff4fc3f7);
  static Color otherMessageBackgroundColor = Colors.white;

  static Color selfMessageColor = Colors.white;
  static Color otherMessageColor = Color(0xff3f3f3f);

  static Color greyColor = Colors.grey;
}

class GradientFab extends StatelessWidget {
  const GradientFab({
    Key key,
    this.animation,
    this.vsync,
    this.elevation,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

  final Animation<double> animation;
  final TickerProvider vsync;
  final VoidCallback onPressed;
  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    var fab = FloatingActionButton(
      heroTag: "btn2",
      elevation: elevation != null ? elevation : 6,
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomRight,
                colors: [
                  Palette.gradientStartColor,
                  Palette.gradientEndColor
                ])),
        child: child,
      ),
      onPressed: onPressed,
    );
    return animation != null
        ? AnimatedSize(
            duration: Duration(milliseconds: 1000),
            curve: Curves.linear,
            vsync: vsync,
            child: ScaleTransition(scale: animation, child: fab))
        : fab;
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final type;
  VideoPlayerWidget(this.videoUrl, this.type);

  @override
  _VideoPlayerWidgetState createState() =>
      _VideoPlayerWidgetState(videoUrl, type);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final VideoPlayerController videoPlayerController;
  final String videoUrl;
  final type;
  double videoDuration = 0;
  double currentDuration = 0;
  _VideoPlayerWidgetState(this.videoUrl, this.type)
      : videoPlayerController = type == 'file'
            ? VideoPlayerController.file(File(videoUrl))
            : VideoPlayerController.network(videoUrl);

  @override
  void initState() {
    super.initState();
    videoPlayerController.initialize().then((_) {
      setState(() {
        videoDuration =
            videoPlayerController.value.duration.inMilliseconds.toDouble();
      });
    });

    videoPlayerController.addListener(() {
      setState(() {
        currentDuration =
            videoPlayerController.value.position.inMilliseconds.toDouble();
      });
    });
    print(videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (videoPlayerController.value.buffered.length != 0 &&
                            videoPlayerController.value.position ==
                                videoPlayerController.value.buffered[0].end) {
                          videoPlayerController.seekTo(Duration(seconds: 0));
                        }
                        videoPlayerController.value.isPlaying
                            ? videoPlayerController.pause()
                            : videoPlayerController.play();
                      });
                    },
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      constraints: BoxConstraints(maxHeight: 400),
                      child: videoPlayerController.value.initialized
                          ? AspectRatio(
                              aspectRatio:
                                  videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(videoPlayerController),
                            )
                          : Container(
                              height: 200,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: IconButton(
                  //     icon: Icon(Icons.fullscreen),
                  //     onPressed: () {},
                  //   ),
                  // ),
                  Align(
                    alignment: Alignment.center,
                    child: videoPlayerController.value.isPlaying
                        ? Container()
                        : GradientFab(
                            elevation: 0,
                            child: Icon(
                              videoPlayerController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                if (videoPlayerController
                                            .value.buffered.length !=
                                        0 &&
                                    videoPlayerController.value.position ==
                                        videoPlayerController
                                            .value.buffered[0].end) {
                                  videoPlayerController
                                      .seekTo(Duration(seconds: 0));
                                }
                                if (videoPlayerController.value.isPlaying) {
                                  videoPlayerController.pause();
                                } else {
                                  videoPlayers.forEach((videoPlayer) {
                                    if (videoPlayer != null) {
                                      videoPlayer.pause();
                                    }
                                    print('player state forEeach $videoPlayer');
                                  });
                                  videoPlayers.add(videoPlayerController);
                                  videoPlayerController.play();
                                }
                              });
                            }),
                  )
                ],
              ),
            ),
            // Slider(
            //   value: currentDuration,
            //   max: videoDuration,
            //   onChanged: (value) => videoPlayerController
            //       .seekTo(Duration(milliseconds: value.toInt())),
            // ),
          ],
        ));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
