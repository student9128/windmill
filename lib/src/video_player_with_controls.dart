import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/linear_percent_indiacator.dart';
import 'package:windmill/src/player_controls.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/util/widget_utils.dart';
import 'package:windmill/src/wind_controller.dart';

class VideoPlayerWithControls extends StatefulWidget {
  final double volumeProgress;

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

  /// 是否收藏
  final bool hasCollected;

  /// 标题
  final String title;

  ///字幕
  final String subtitle;

  final PlayerNotifier? notifier;


  const VideoPlayerWithControls(
      {Key? key,
      required this.volumeProgress,
      this.showControls = false,
      this.bottomHeight = 30,
      this.onBackClick,
      this.onRotateScreenClick,
      this.onCollectClick,
      this.onShareClick,
      this.onPipClick,
      this.onVideoProgress,
      this.hasCollected = false,
      this.title = '',
      this.subtitle = '',
      this.notifier})
      : super(key: key);

  @override
  State<VideoPlayerWithControls> createState() =>
      _VideoPlayerWithControlsState();
}

class _VideoPlayerWithControlsState extends State<VideoPlayerWithControls> {
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var playerNotifier=Provider.of<PlayerNotifier>(context);
    final WindController windController = WindController.of(context);
    double calculateAspectRatio(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final height = size.height;
      return width > height ? width / height : height / width;
    }

    Widget buildPlayerWithControls(
        BuildContext context, WindController windController) {
          debugPrint('widget.notifier.showVolumeProgress===${playerNotifier.showVolumeProgress}');
          debugPrint('widget.notifier.showVolumeProgress=widget==${widget.notifier?.showVolumeProgress}');
      return Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: windController.aspectRatio ??
                  windController.videoPlayerController.value.aspectRatio,
              child: VideoPlayer(windController.videoPlayerController),
            ),
          ),
          // playerNotifier.showVolumeProgress
          //     ? Container(
          //         alignment: Alignment.center,
          //         child: Container(
          //           width: 200,
          //           height: 50,
          //           decoration: BoxDecoration(
          //               color: const Color(0xe0000000),
          //               borderRadius: BorderRadius.circular(5.0)),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               buildImage('icon_volume'),
          //               LinearPercentIndicator(
          //                 width: 140,
          //                 progressColor:const Color(0xffFFECC8),
          //                 percent: playerNotifier.volumeProgress,
          //                 barRadius: const Radius.circular(5),
          //               )
          //             ],
          //           ),
          //         ))
          //     : Container(),
          // playerNotifier.showBrightnessProgress
          //     ? Container(
          //         alignment: Alignment.center,
          //         child: Container(
          //           width: 200,
          //           height: 50,
          //           decoration: BoxDecoration(
          //               color: const Color(0xe0000000),
          //               borderRadius: BorderRadius.circular(5.0)),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               buildImage('icon_brightness'),
          //               LinearPercentIndicator(
          //                 width: 140,
          //                 progressColor:const Color(0xffFFECC8),
          //                 percent: playerNotifier.brightnessProgress,
          //                 barRadius: const Radius.circular(5),
          //               )
          //             ],
          //           ),
          //         ))
          //     : const SizedBox(),
          Container(
              child: PlayerControls(
            controller: windController.videoPlayerController,
            subTitle: widget.subtitle,
            onBackClick: () {
              widget.onBackClick?.call();
            },
          ))
        ],
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(context),
          child: buildPlayerWithControls(context, windController),
        ),
      ),
    );
  }
}
