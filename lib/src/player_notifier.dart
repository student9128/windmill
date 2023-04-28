import 'dart:io';

import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/material.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:video_player/video_player.dart';

class PlayerNotifier extends ChangeNotifier {
  PlayerNotifier._(
      bool hideStuff,
      ) : _hideStuff = hideStuff;

  bool _hideStuff;

  bool get hideStuff => _hideStuff;

  void setHideStuff(bool value) {
    _hideStuff = value;
    notifyListeners();
  }
  // ignore: prefer_constructors_over_static_methods
  static PlayerNotifier init() {
    _initVolumeAndBrightness();
    return PlayerNotifier._(
      true,
    );
  }

  bool _showVolumeProgress = false;
  bool get showVolumeProgress => _showVolumeProgress;
  void setShowVolumeProgress(bool b) {
    _showVolumeProgress =b;
    notifyListeners();
  }

  bool _showBrightnessProgress=false;
  bool get showBrightnessProgress=>_showBrightnessProgress;
   void setShowBrightnessProgress(bool b) {
    _showBrightnessProgress = b;
    notifyListeners();
  }
  static double _volumeProgress = 0.0;
  double get volumeProgress => _volumeProgress;
  void setVolumeProgress(double dy) async {
    _volumeProgress = _volumeProgress - dy / 100;
    if (_volumeProgress <= 0) {
      _volumeProgress = 0;
    }
    if (_volumeProgress > 1.0) {
      _volumeProgress = 1.0;
    }
    PerfectVolumeControl.setVolume(_volumeProgress);
    if(!showVolumeProgress){
    _showVolumeProgress = true;
    }
    notifyListeners();
  }

  static double _brightnessProgress = 0.0;
  double get brightnessProgress => _brightnessProgress;
  void setBrightnessProgress(double dy) async{
     _brightnessProgress = _brightnessProgress - dy / 100;
    if (_brightnessProgress < 0) {
      _brightnessProgress = 0;
    }
    if (_brightnessProgress > 1.0) {
      _brightnessProgress = 1.0;
    }
    DeviceDisplayBrightness.setBrightness(_brightnessProgress);
    if(!_showBrightnessProgress){
      _showBrightnessProgress=true;
    }
    notifyListeners();
  }

  static _initVolumeAndBrightness() async {
    PerfectVolumeControl.hideUI = true;
    _volumeProgress = await PerfectVolumeControl.getVolume();
    _brightnessProgress = await DeviceDisplayBrightness.getBrightness();
  }
  bool _isPlayingWhenDragStart=true;
  bool get isPlayingWhenDragStart=>_isPlayingWhenDragStart;
  void setPlayStatusWhenDragStart(bool b) {
    if (_isPlayingWhenDragStart == b) return;
    _isPlayingWhenDragStart = b;
    notifyListeners();
  }


  bool _isLocked = false;
  bool get isLocked => _isLocked;
  void setLocked(bool b) {
    if (_isLocked == b) return;
    _isLocked = b;
    notifyListeners();
  }
  bool _showWidget = false;
  bool get showWidget =>_showWidget;
  void setShowWidget(bool b){
    _showWidget=b;
    _showLockIcon=b;
    notifyListeners();
  }

  void toggleLocked() {
    _isLocked = !_isLocked;
    notifyListeners();
  }

  bool _showLockIcon = false;
  bool get showLockIcon => _showLockIcon;
  void setShowLockIcon(bool b) {
    _showLockIcon = b;
    notifyListeners();
  }

  bool _showSettingModal = false;
  bool get showSettingModal => _showSettingModal;
  void setShowSettingModal(bool b) {
    _showSettingModal = b;
    notifyListeners();
  }
  bool _allowBackgroundPlay = true;
  bool get allowBackgroundPlay => _allowBackgroundPlay;
  void setAllowBackgroundPlay(bool b) {
    _allowBackgroundPlay = b;
    notifyListeners();
  }
  int _currentSpeedIndex=0;
  int get currentSpeedIndex=>_currentSpeedIndex;
  void setCurrentSpeedIndex(int index){
    _currentSpeedIndex=index;
    notifyListeners();
  }
  int _remoteUid = -1;
  int get remoteUid =>_remoteUid;
  void setRemoteUid(int uid){
    _remoteUid = uid;
    notifyListeners();
  }
  String _channelName = "";
  String get channelName =>_channelName;
  void setChannelName(String str){
    _channelName = str;
    notifyListeners();
  }

   Duration _currentPos = const Duration(seconds: 0);
  Duration? _oldPos;
  int _equalCount = 0;
  bool _isPlaying = true;
  bool get isPlaying=>_isPlaying;
  updateState(VideoPlayerController controller){
      _currentPos = controller.value.position;
    if (_currentPos == _oldPos && controller.value.isPlaying) {
      _equalCount++;
      //处理播放视频时候可能出现的来电话，导致视频暂停，这里_isPlaying用来修改播放暂停按钮的状态
      if (_equalCount > 5 && _isPlaying) {
        _isPlaying = false;
      }
    } else {
      _oldPos = _currentPos;
      _equalCount = 0;
      if (!_isPlaying) {
        _isPlaying = true;
      }
    }
    _processTotalDuration(controller.value.duration);
    _processPosition(controller, _currentPos);
  }

///格式化视频时间
  _processDuration(Duration duration) {
    var durationTemp = duration.toString();
    var index = durationTemp.indexOf('.');
    var colonIndex = durationTemp.indexOf(":");
    if (index != -1) {
      durationTemp = durationTemp.substring(0, index);
    }
    if (colonIndex == 1) {
      var first = durationTemp.substring(0, 1);
      if (first == '0') {
        durationTemp = durationTemp.substring(2, durationTemp.length);
      } else {
        durationTemp = '0$durationTemp';
      }
    } else {
      durationTemp = '0$durationTemp';
    }
    return durationTemp;
  }
  _processTotalDuration(Duration duration) {
    String temp = _processDuration(duration);
    if (_duration == temp) return;
    _duration = temp;
    notifyListeners();
  }
  String _duration = '';
  String get duration => _duration;
  String _position = '';
  String get position => _position;
  Duration _lastDuration = Duration.zero;
  Duration get lastDuration => _lastDuration;
  ///ios端播放m3u8的时，拖动进度条会出现进度条跳动的现象
  _processPosition(VideoPlayerController controller, Duration duration) {
    String temp = _processDuration(duration);
    if (_position == temp){
      notifyListeners();
      return;
    }
    if (Platform.isIOS) {
      if (_isDragEnd) {
        //松手后，判断position是否在buffer范围内，不在则不赋值，显示进度圈
        if (controller.value.buffered.isNotEmpty) {
          final buffered = controller.value.buffered[0];
          if (duration.inMilliseconds >= buffered.start.inMilliseconds &&
              duration.inMilliseconds <= buffered.end.inMilliseconds) {
            _position = temp;
            _lastDuration = duration;
            _isDragEnd = false;
            _showProgress = false;
          } else {
            _showProgress = true;
          }
        } else {
          _showProgress = true;
        }
      } else {
        _position = temp;
        _lastDuration = duration;
      }
    } else {
      _position = temp;
      _lastDuration = duration;
      _showProgress = false;
    }
    notifyListeners();
  }


  bool _showProgress=false;
  bool get showProgress=>_showProgress;
  bool _isDragEnd=false;
  bool _isPlayingBeforeDrag=false;
  progressDragStartX({bool isPlaying=false}) {
    _isDragEnd = false;
    _isPlayingBeforeDrag=isPlaying;
    notifyListeners();
  }

  progressDragUpdateX(double x) {
  }

  progressDragEndX() {
    _isDragEnd = true;
    _showProgress=_isPlayingBeforeDrag;
    notifyListeners();
  }
}