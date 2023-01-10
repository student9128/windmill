import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/linear_percent_indiacator.dart';
import 'package:windmill/src/wind_controller.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:windmill/src/wind_live_controller.dart';
class LivePlayerWithControls extends StatefulWidget {
  final double volumeProgress;
  final int userId;
  const LivePlayerWithControls({Key? key,required this.volumeProgress,required this.userId}) : super(key: key);

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
    final WindLiveController windLiveController = WindLiveController.of(context);
    double calculateAspectRatio(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final width = size.width;
      final height = size.height;
      return width > height ? width / height : height / width;
    }
    Widget buildPlayerWithControls(BuildContext context,WindLiveController windController){
      return Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1.77/1,
              child: rtc_local_view.TextureView(
                // uid:widget.userId,
                channelId: 'TEST_CHANNEL',
              ),
            ),
          ),
          Positioned(
            bottom: 10,
              right: 10,
              child:  ElevatedButton(onPressed:(){
                windLiveController.toggleFullScreen();
          }, child: Text('测试全屏'))),
          Positioned(
            left: 10,
              top: 50,
              child: Row(
      children: [
        Text('声音'),
        LinearPercentIndicator(
          width: 140,
          progressColor: Colors.amber,
          percent: widget.volumeProgress,
          barRadius: Radius.circular(5),
        )
      ],
      )),
        ],
      );
    }
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AspectRatio(aspectRatio: calculateAspectRatio(context),
          child: buildPlayerWithControls(context,windLiveController),
          
        ),
      ),
    );
  }
}
