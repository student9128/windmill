import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/video_player_with_controls.dart';
import 'package:windmill/src/wind_controller.dart';
import 'package:windmill/src/wind_video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final WindController controller;

  /// 是否收藏
  final bool hasCollected;

  /// 标题
  final String title;

  ///字幕
  final String subtitle;
  const FullScreenVideo(
      {Key? key,
      required this.controller,
      this.hasCollected = false,
      this.title = '',
      this.subtitle = ''})
      : super(key: key);

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late PlayerNotifier notifier;

  bool get isControllerFullScreen => widget.controller.isFullScreen;

  final double _volumeProgress = 0.0;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    widget.controller.addListener(listener);
    notifier = PlayerNotifier.init();
  }
  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WindControllerProvider(
          controller: widget.controller,
          child: ChangeNotifierProvider<PlayerNotifier>.value(
            value: notifier,
            builder: (context, child) {
              return GestureDetector(
                onTap: () {},
                onVerticalDragDown: (v) {},
                onVerticalDragUpdate: (v) {
                  if(notifier.isLocked||!widget.controller.enableGesture)return;
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
                  if(notifier.isLocked||!widget.controller.enableGesture)return;
                  notifier.setShowVolumeProgress(false);
                  notifier.setShowBrightnessProgress(false);
                },
                  onHorizontalDragUpdate: (v) {
                  if (notifier.isLocked||!widget.controller.enableGesture) return;
                  var currentPos =
                      widget.controller.videoPlayerController.value.position;
                  var dx = v.delta.dx;
                  currentPos +=
                      widget.controller.videoPlayerController.value.duration *
                          (dx / 1000);
                  widget.controller.seekTo(currentPos);
                },
                child: VideoPlayerWithControls(
                  volumeProgress: _volumeProgress,
                  subtitle: widget.subtitle,
                  title: widget.title,
                  onRotateScreenClick: (landscape) {
                    Navigator.pop(context);
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: [SystemUiOverlay.top,SystemUiOverlay.bottom]);
                  },
                ),
              );
            },
          )),
    );
  }
}
