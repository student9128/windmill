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
    _showVolumeProgress = b;
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
    await PerfectVolumeControl.setVolume(_volumeProgress);
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
    await DeviceDisplayBrightness.setBrightness(_brightnessProgress);
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

  // ignore: prefer_constructors_over_static_methods
  static PlayerNotifier init() {
    _initVolumeAndBrightness();
    return PlayerNotifier._(
      true,
    );
  }
}