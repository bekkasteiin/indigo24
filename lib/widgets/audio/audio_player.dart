import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/style/colors.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final String url;
  final PlayerMode mode;

  PlayerWidget(
      {Key key, @required this.url, this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

List<AudioPlayer> audioPlayers = [];

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get isPaused => _playerState == PlayerState.paused;
  get _durationText =>
      _duration?.toString()?.replaceFirst('0:', '')?.split('.')?.first ?? '';
  get _positionText =>
      _position?.toString()?.replaceFirst('0:', '')?.split('.')?.first ?? '';

  get isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  _PlayerWidgetState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _isPlaying
                ? InkWell(
                    onTap: _isPlaying ? () => _pause() : null,
                    child: Image.asset(
                      'assets/images/pause.png',
                      width: 30,
                      height: 30,
                    ),
                  )
                : InkWell(
                    onTap: _isPlaying ? null : () => _play(),
                    child: Image.asset(
                      'assets/images/play.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
            Expanded(
              child: Container(
                child: Slider(
                  activeColor: primaryColor,
                  inactiveColor: greyColor,
                  onChanged: (v) {
                    final p = v * _duration.inMilliseconds;
                    _audioPlayer.seek(Duration(milliseconds: p.round()));
                  },
                  value: (_position != null &&
                          _duration != null &&
                          _position.inMilliseconds > 0 &&
                          _position.inMilliseconds < _duration.inMilliseconds)
                      ? _position.inMilliseconds / _duration.inMilliseconds
                      : 0.0,
                ),
              ),
            ),
          ],
        ),
        Text(
          _position != null
              ? '${_positionText ?? ''} / ${_durationText ?? ''}'
              : _duration != null
                  ? _durationText
                  : '',
          style: TextStyle(
            fontSize: 10.0,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  Future<int> _play() async {
    audioPlayers.forEach((audioPlayer) {
      if (audioPlayer != null) {
        audioPlayer.pause();
      }
    });
    if (!audioPlayers.contains(_audioPlayer)) {
      audioPlayers.add(_audioPlayer);
    }
    int result = 0;
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    _audioPlayer.setPlaybackRate(playbackRate: 1);
    if (_position == null ||
        _position.inMilliseconds == 0 ||
        _position.inMilliseconds == null ||
        _position == _duration) {
      result = await _audioPlayer.play(url, position: playPosition);
      if (result == 1) setState(() => _playerState = PlayerState.playing);

      return result;
    } else {
      result = await _audioPlayer.resume();
      if (result == 1) setState(() => _playerState = PlayerState.playing);

      return result;
    }

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }

  Future<int> stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _position = Duration();
        _playerState = PlayerState.stopped;
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
