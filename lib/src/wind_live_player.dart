import 'dart:io';

import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:provider/provider.dart';
import 'package:windmill/src/full_screen_live.dart';
import 'package:windmill/src/live_player_with_controls.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/wind_live_controller.dart';

///直播横竖屏切换策略是直接在当前页面旋转
///
///
class WindLivePlayer extends StatefulWidget {
  final WindLiveController controller;
  final Function? needRefresh;
    /// 标题
  final String title;

  ///字幕
  final String subtitle;
  final Function(bool landscape)? onRotateScreenClick;

  const WindLivePlayer(
      {Key? key,
      required this.controller,
      this.needRefresh,
      this.onRotateScreenClick,
      this.title = '',
      this.subtitle = ''})
      : super(key: key);

  @override
  State<WindLivePlayer> createState() => _WindLivePlayerState();
}

class _WindLivePlayerState extends State<WindLivePlayer> {
  late PlayerNotifier notifier;
  double _brightnessProgress = 0.0;
  double _volumeProgress = 0.0;
  double _currentVolume = 0.0;
  bool _isFullScreen = false;

  bool get isControllerFullScreen => widget.controller.isFullScreen;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
    notifier = PlayerNotifier.init();
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   notifier.setChannelName(widget.channelName);
    // });
  }

  _initVolumeAndBrightness() async {
    PerfectVolumeControl.hideUI = true;
    double volume = await PerfectVolumeControl.getVolume();
    _volumeProgress = volume;
    _currentVolume = volume;
    double brightness = await DeviceDisplayBrightness.getBrightness();
    _brightnessProgress = brightness;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
    setState(() {
      
    });
    debugPrint('wind===isControllerFullScreen=$isControllerFullScreen,_isFullScreen=$_isFullScreen');
    // if (isControllerFullScreen && !_isFullScreen) {
    //   _isFullScreen = isControllerFullScreen;
    //   debugPrint('wind=========windVideo enterFull');
    //   Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {
    //     return FullScreenLive(controller: widget.controller);
    //   })).then((value){
    //   widget.onRotateScreenClick?.call(false);
    //     debugPrint('wind=========windVideo back');
    //     // _initVolumeAndBrightness();
    //     // widget.needRefresh?.call();
    //     // widget.controller.refresh();
    //   });
    // //    SystemChrome.setPreferredOrientations([
    // //   // DeviceOrientation.landscapeLeft,
    // //   Platform.isIOS?
    // //   DeviceOrientation.landscapeRight:DeviceOrientation.landscapeLeft,
    // // ]);
    // // setState(() {
    // // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // // });
    // } else {
    //   widget.onRotateScreenClick?.call(true);
    //   Navigator.of(
    //     context,
    //   ).pop();
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.portraitUp,
    //     DeviceOrientation.portraitDown,
    //   ]);
    //   setState(() {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //       overlays: [SystemUiOverlay.top]);
    //   });
    //   debugPrint('wind=========windVideo exit');
    //   _isFullScreen = false;
    // }
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
    return WindLiveControllerProvider(
        controller: widget.controller,
        child: ChangeNotifierProvider<PlayerNotifier>.value(
          value: notifier,
          builder: (context, child) {
            // if(_uid==-1)return Container(color: Colors.red,width: 100,height: 100,);
            return GestureDetector(
              onTap: () {},
              onVerticalDragDown: (v) {},
              onVerticalDragUpdate: (v) {
                var dy = v.delta.dy;
                setVolume(dy);
              },
              onVerticalDragCancel: () {},
              child: LivePlayerWithControls(
                title: widget.title,
                subtitle: widget.subtitle,
                volumeProgress: _volumeProgress,
              ),
            );
          },
        ));
  }
}

class WindLiveControllerProvider extends InheritedWidget {
  final WindLiveController controller;

  const WindLiveControllerProvider(
      {Key? key, required this.controller, required Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant WindLiveControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
