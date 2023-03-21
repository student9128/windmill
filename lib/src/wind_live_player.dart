
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:provider/provider.dart';
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
  double _volumeProgress = 0.0;
  double _currentVolume = 0.0;
  final bool _isFullScreen = false;

  bool get isControllerFullScreen => widget.controller.isFullScreen;

  @override
  void initState() {
    super.initState();
    notifier = PlayerNotifier.init();
  }

  @override
  void dispose() {
    super.dispose();
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
      : super(key: key,child: child);

  @override
  bool updateShouldNotify(covariant WindLiveControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
