import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:provider/provider.dart';
import 'package:windmill/src/live_player_with_controls.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/wind_live_controller.dart';
import 'package:windmill/src/wind_live_player.dart';
class FullScreenLive extends StatefulWidget {
  final WindLiveController controller;

  /// 标题
  final String title;

  ///字幕
  final String subtitle;
  const FullScreenLive(
      {Key? key, required this.controller, this.title = '', this.subtitle = ''})
      : super(key: key);

  @override
  State<FullScreenLive> createState() => _FullScreenLiveState();
}

class _FullScreenLiveState extends State<FullScreenLive> {
  bool _isFullScreen = false;
  late PlayerNotifier notifier;

  bool get isControllerFullScreen => widget.controller.isFullScreen;

  double _brightnessProgress = 0.0;
  double _volumeProgress = 0.0;
  double _currentVolume = 0.0;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
    notifier = PlayerNotifier.init();
    _initVolumeAndBrightness();
  }
  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
    // if (isControllerFullScreen && !_isFullScreen) {
    //   _isFullScreen = isControllerFullScreen;
    //   debugPrint('wind=========fullScreen enterFull');
    // } else if (_isFullScreen) {
    //   Navigator.of(
    //     context,
    //     // rootNavigator: widget.controller.useRootNavigator,
    //   ).pop();
    //   _isFullScreen = false;
    //   debugPrint('wind=========fullScreen exit');
    // }
  }
  _initVolumeAndBrightness() async{
    PerfectVolumeControl.hideUI = true;
    double volume = await PerfectVolumeControl.getVolume();
    _volumeProgress = volume;
    _currentVolume = volume;
    double brightness = await DeviceDisplayBrightness.getBrightness();
    _brightnessProgress = brightness;
    setState(() {

    });
  }
  setVolume(double dy) async {
    _currentVolume = _currentVolume - dy / 100;
    if (_currentVolume <= 0) {
      _currentVolume = 0;
    }
    if (_currentVolume > 1.0) {
      _currentVolume = 1.0;
    }
    setState(() {
      _volumeProgress = _currentVolume;
    });
    await PerfectVolumeControl.setVolume(_currentVolume);
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
       return Scaffold(
      backgroundColor: Colors.black,
      body: WindLiveControllerProvider(
          controller: widget.controller,
          child: ChangeNotifierProvider<PlayerNotifier>.value(
            value: notifier,
            builder: (context, child) {
              return GestureDetector(
                onTap: () {},
                onVerticalDragDown: (v) {},
                onVerticalDragUpdate: (v) {
                  if(notifier.isLocked)return;
                  var screenWidth = MediaQuery.of(context).size.width;
                  var dy = v.delta.dy;
                  var dx = v.localPosition.dx;
                  if (dx < screenWidth / 2) {
                    notifier.setBrightnessProgress(dy);
                  } else {
                    notifier.setVolumeProgress(dy);
                  }
                },
                onVerticalDragCancel: () {},
                onVerticalDragEnd: (v) {
                  if(notifier.isLocked)return;
                  notifier.setShowVolumeProgress(false);
                  notifier.setShowBrightnessProgress(false);
                },
                child: LivePlayerWithControls(volumeProgress: _volumeProgress,subtitle:widget.subtitle,),
              );
            },
          )),
    );
  }
}
