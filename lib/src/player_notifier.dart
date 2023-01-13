import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/material.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

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

  bool _showVolumeProgress = false;
  bool get showVolumeProgress => _showVolumeProgress;
  void setShowVolumeProgress(bool b) {
    debugPrint('wind========setShow $b');
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
    debugPrint('wind========setShow setVolumeProgress dy');
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
    notifyListeners();
  }

  void toggleLocked() {
    _isLocked = !_isLocked;
    notifyListeners();
  }

  bool _showSettingModal = false;
  bool get showSettingModal =>_showSettingModal;
  void setShowSettingModal(bool b){
    _showSettingModal=b;
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

  // ignore: prefer_constructors_over_static_methods
  static PlayerNotifier init() {
    _initVolumeAndBrightness();
    return PlayerNotifier._(
      true,
    );
  }
}