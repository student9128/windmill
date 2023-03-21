import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windmill/src/live_player_controls.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:windmill/src/wind_live_controller.dart';

class LivePlayerWithControls extends StatefulWidget {
  final double volumeProgress;

  /// 返回点击
  final Function? onBackClick;

  /// 标题
  final String title;

  ///字幕
  final String subtitle;
  const LivePlayerWithControls({
    Key? key,
    required this.volumeProgress,
    this.onBackClick,
    this.title = '',
    this.subtitle = '',
  }) : super(key: key);

  @override
  State<LivePlayerWithControls> createState() => _LivePlayerWithControlsState();
}

class _LivePlayerWithControlsState extends State<LivePlayerWithControls> {
  @override
  void initState() {
    super.initState();
    debugPrint('LivePlayer==========initState');
  }

  @override
  void dispose() {
    debugPrint('LivePlayer==========dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WindLiveController windLiveController =
        WindLiveController.of(context);
    double calculateAspectRatio(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final height = size.height;
      return width > height ? width / height : height / width;
    }

    Widget buildPlayerWithControls(
        BuildContext context, WindLiveController windController) {
      WindLiveController windLiveController = WindLiveController.of(context);
      debugPrint(
          'liveVideo========joinChange=123---${windLiveController.remoteUid},${windLiveController.channelId}');
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1.77 / 1,
                child: rtc_remote_view.TextureView(
                  uid: windLiveController.remoteUid,
                  channelId: windLiveController.channelId,
                ),
              ),
            ),
            LivePlayerControls(
              title: widget.title,
              subTitle: widget.subtitle,
              onBackClick: () {
                widget.onBackClick?.call();
              },
            )
          ],
        ),
      );
    }

    if (windLiveController.isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(context),
          child: buildPlayerWithControls(context, windLiveController),
        ),
      ),
    );
  }
}
