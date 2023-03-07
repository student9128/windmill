import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

///播放视频直接进入横屏
  final bool showFullScreen;

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
    this.showFullScreen=false,
    this.hasCollected = false,
    this.title = '',
    this.subtitle = ''})
      : super(key: key);

  @override
  State<WindVideoPlayer> createState() => _WindVideoPlayerState();
}

class _WindVideoPlayerState extends State<WindVideoPlayer> {
  final bool _isFullScreen = false;
  late PlayerNotifier notifier;

  bool get isControllerFullScreen => widget.controller.isFullScreen;

  final double _volumeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // widget.controller.addListener(listener);
    notifier = PlayerNotifier.init();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(widget.showFullScreen){
        widget.controller.toggleFullScreen();
        enterFullScreen(context);
      }
     });
  }

  // _initVolumeAndBrightness() async {
  //   PerfectVolumeControl.hideUI = true;
  //   double volume = await PerfectVolumeControl.getVolume();
  //   _volumeProgress = volume;
  //   double brightness = await DeviceDisplayBrightness.getBrightness();
  //   setState(() {});
  // }

  @override
  void dispose() {
    // widget.controller.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
    debugPrint('wind===isControllerFullScreen=$isControllerFullScreen,_isFullScreen=$_isFullScreen');
    // if (isControllerFullScreen && !_isFullScreen) {
    //   _isFullScreen = isControllerFullScreen;
    //   debugPrint('wind=========windVideo enterFull');
    //   Navigator.of(context)
    //       .push(CupertinoPageRoute(builder: (BuildContext context) {
    //     return FullScreenVideo(controller: widget.controller,subtitle: widget.subtitle,title: widget.title,);
    //   })).then((value) {
    //     debugPrint('wind=========windVideo back');
    //     // _initVolumeAndBrightness();
    //     widget.needRefresh?.call();
    //   });
    // } else {
    //   Navigator.of(
    //     context,
    //     // rootNavigator: widget.controller.useRootNavigator,
    //   ).pop();
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.portraitUp,
    //     DeviceOrientation.portraitDown,
    //   ]);
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //       overlays: [SystemUiOverlay.top]);
    //   debugPrint('wind=========windVideo exit');
    //   _isFullScreen = false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WindControllerProvider(
        controller: widget.controller,
        child: ChangeNotifierProvider<PlayerNotifier>.value(
          value: notifier,
          builder: (BuildContext context,Widget? child) {
            return VideoPlayerWithControls(
                notifier: notifier,
                volumeProgress: _volumeProgress,
                showControls:true,
                title:widget.title,
                subtitle:widget.subtitle,
                onBackClick: () {
                  Navigator.pop(context);
                },
                onRotateScreenClick: (landscape) {
                if (landscape) {
                  //横屏就切换为竖屏
                  exitFullScreen(context);
                } else {
                  //竖屏就切换为横屏
                  enterFullScreen(context);
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
            );
          },
        ));
  }

  void exitFullScreen(BuildContext context) {
      Navigator.of(context).pop();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  void enterFullScreen(BuildContext context) {
       Navigator.of(context)
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return FullScreenVideo(
        controller: widget.controller,
        subtitle: widget.subtitle,
        title: widget.title,
      );
    })).then((value) {
      debugPrint('wind=========windVideo back');
      widget.needRefresh?.call();
    });
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
