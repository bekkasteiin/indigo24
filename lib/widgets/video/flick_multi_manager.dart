import 'package:flick_video_player/flick_video_player.dart';

class FlickMultiManager {
  List<FlickManager> _flickManagers = [];
  FlickManager _activeManager;
  bool _isMute = false;

  init(FlickManager flickManager) {
    _flickManagers.add(flickManager);
    if (_isMute) {
      flickManager?.flickControlManager?.mute();
    } else {
      flickManager?.flickControlManager?.unmute();
    }

    _flickManagers.forEach((manager) => manager.flickControlManager.mute());

    if (_flickManagers.length == 1) {
      play(flickManager);
    }
  }

  dispose() {
    _activeManager.dispose();
  }

  remove(FlickManager flickManager) {
    if (_activeManager == flickManager) {
      _activeManager = null;
    }
    flickManager.dispose();
    _flickManagers.remove(flickManager);
  }

  removeAll() {
    _flickManagers.forEach((manager) => _flickManagers.remove(manager));
  }

  togglePlay(FlickManager flickManager) {
    if (_activeManager?.flickVideoManager?.isPlaying == true &&
        flickManager == _activeManager) {
      pause();
    } else {
      play(flickManager);
    }
  }

  pause() {
    _activeManager?.flickControlManager?.pause();
  }

  play([FlickManager flickManager]) {
    if (flickManager != null) {
      _activeManager?.flickControlManager?.pause();
      _activeManager = flickManager;
    }
    _activeManager?.flickControlManager?.play();
  }

  toggleMute() {
    _activeManager?.flickControlManager?.toggleMute();
    _isMute = _activeManager?.flickControlManager?.isMute;
    if (_isMute) {
      _flickManagers.forEach((manager) => manager.flickControlManager.mute());
    } else {
      _flickManagers.forEach((manager) => manager.flickControlManager.unmute());
    }
  }
}
