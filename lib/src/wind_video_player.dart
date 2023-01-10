import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:provider/provider.dart';
import 'package:windmill/src/full_screen_video.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/video_player_with_controls.dart';
import 'package:windmill/src/wind_controller.dart';

///视频播放横竖屏切换策略是进行页面跳转
class WindVideoPlayer extends StatefulWidget {
  final WindController controller;
  final Function? needRefresh;
  ///是否显示视频画面上面的组件
  final bool showControls;

  /// 底部按钮容器高度
  final double bottomHeight;

  /// 返回点击
  final Function? onBackClick;

  /// 横竖屏切换点击
  final Function(bool landscape)? onRotateScreenClick;

  /// 视频进度回调
  final Function(String time)? onVideoProgress;

  /// 收藏点击
  final Function? onCollectClick;

  /// 分享点击
  final Function? onShareClick;

  /// 画中画点击
  final Function? onPipClick;

  ///设置点击
  final Function? onSettingClick;

  /// 是否收藏
  final bool hasCollected;

  /// 标题
  final String title;

  ///字幕
  final String subtitle;

  const WindVideoPlayer({Key? key, required this.controller, this.needRefresh,
    this.showControls = false,
    this.bottomHeight = 30,
    this.onBackClick,
    this.onRotateScreenClick,
    this.onCollectClick,
    this.onShareClick,
    this.onPipClick,
    this.onSettingClick,
    this.onVideoProgress,
    this.hasCollected = false,
    this.title = '',
    this.subtitle = ''})
      : super(key: key);

  @override
  State<WindVideoPlayer> createState() => _WindVideoPlayerState();
}

class _WindVideoPlayerState extends State<WindVideoPlayer> {
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
    // _initVolumeAndBrightness();
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
    debugPrint('wind===isControllerFullScreen=$isControllerFullScreen,_isFullScreen=$_isFullScreen');
    if (isControllerFullScreen && !_isFullScreen) {
      _isFullScreen = isControllerFullScreen;
      debugPrint('wind=========windVideo enterFull');
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (BuildContext context) {
        return FullScreenVideo(controller: widget.controller);
      })).then((value) {
        debugPrint('wind=========windVideo back');
        // _initVolumeAndBrightness();
        widget.needRefresh?.call();
      });
    } else {
      Navigator.of(
        context,
        // rootNavigator: widget.controller.useRootNavigator,
      ).pop();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top]);
      debugPrint('wind=========windVideo exit');
      _isFullScreen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return WindControllerProvider(
        controller: widget.controller,
        child: ChangeNotifierProvider<PlayerNotifier>.value(
          value: notifier,
          builder: (BuildContext context,Widget? child) {
            return GestureDetector(
              onTap: () {},
              onVerticalDragDown: (v) {},
              onVerticalDragUpdate: (v) {
                var dy = v.delta.dy;
                var dx = v.localPosition.dx;
                if (dx < screenWidth / 2) {
                  notifier.setBrightnessProgress(dy);
                } else {
                  notifier.setVolumeProgress(dy);
                }
              },
              onVerticalDragCancel: () {
              },
              onVerticalDragEnd: (v){
                notifier.setShowVolumeProgress(false);
                notifier.setShowBrightnessProgress(false);
                
              },
              child: VideoPlayerWithControls(
                volumeProgress: _volumeProgress,
                showControls:true,
                title:widget.title,
                subtitle:widget.subtitle,
                onBackClick: () {
                  debugPrint('wind============onBackClick');
                  // if (_isFullScreen) {
                  //   SystemChrome.setPreferredOrientations([
                  //     DeviceOrientation.portraitUp,
                  //     DeviceOrientation.portraitDown,
                  //   ]);
                  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  //       overlays: [SystemUiOverlay.top]);
                  // } else {
                  //   widget.onBackClick?.call();
                  // }
                },
                onRotateScreenClick: (landscape) {
                  if (landscape) {
                    //横屏
                  } else {
                    //竖屏
                  }
                },
                onCollectClick: () {
                  widget.onCollectClick?.call();
                },
                onShareClick: () {
                  widget.onShareClick?.call();
                },
                onPipClick: () {
                  widget.onPipClick?.call();
                },
                onVideoProgress: (time) {
                  //time是当前播放到的时间position
                  widget.onVideoProgress?.call(time);
                },
              ),
            );
          },
        ));
  }
}

class WindControllerProvider extends InheritedWidget {
  final WindController controller;

  const WindControllerProvider(
      {Key? key, required this.controller, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(WindControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
