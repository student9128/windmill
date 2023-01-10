import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:provider/provider.dart';
import 'package:windmill/src/linear_percent_indiacator.dart';
import 'package:windmill/src/live_player_with_controls.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/video_player_with_controls.dart';
import 'package:windmill/src/wind_controller.dart';
import 'package:windmill/src/wind_live_controller.dart';
import 'package:windmill/src/wind_live_player.dart';
import 'package:windmill/src/wind_video_player.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
class FullScreenLive extends StatefulWidget {
  final WindLiveController controller;
  const FullScreenLive({Key? key,required this.controller}) : super(key: key);

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
      body: GestureDetector(
        onTap: () {},
        onVerticalDragDown: (v) {},
        onVerticalDragUpdate: (v) {
          var dy = v.delta.dy;
          setVolume(dy);
        },
        onVerticalDragCancel: () {},
        // child: LivePlayerWithControls(volumeProgress: _volumeProgress,userId: -1,),
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1.77/1,
                child: rtc_local_view.SurfaceView(
                  // uid:widget.userId,
                  channelId: 'TEST_CHANNEL',
                ),
              ),
            ),
            // Positioned(
            //     bottom: 10,
            //     right: 10,
            //     child:  ElevatedButton(onPressed:(){
            //       widget.controller.toggleFullScreen();
            //     }, child: Text('测试全屏'))),
            Positioned(
                left: 10,
                top: 50,
                child: Row(
                  children: [
                    Text('声音'),
                    LinearPercentIndicator(
                      width: 140,
                      progressColor: Colors.amber,
                      // percent: widget.volumeProgress,
                      barRadius: Radius.circular(5),
                    )
                  ],
                )),
          ],
        ),
      )
    );
  }
}
