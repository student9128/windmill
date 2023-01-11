import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/linear_percent_indiacator.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/progress_bar.dart';
import 'package:windmill/src/util/asset_utils.dart';
import 'package:windmill/src/util/color_utils.dart';
import 'package:windmill/src/util/widget_utils.dart';
import 'package:windmill/src/util/wind_button.dart';
import 'package:windmill/windmill.dart';

class PlayerControls extends StatefulWidget {
  final VideoPlayerController controller;

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
  final String subTitle;

  const PlayerControls(
      {Key? key,
      required this.controller,
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
      this.subTitle = ''})
      : super(key: key);

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls>
    with TickerProviderStateMixin {
  late AnimationController _animationController, _settingAnimController;
  late Animation _changeOpacity;
  late Animation _changePosition;
  Duration _currentPos = Duration(seconds: 0);
  Duration? _oldPos;
  int _equalCount = 0;
  bool isPlaying = true;
  final _handler = AbsEventHandlerImpl.instance.mHandler;
  late PlayerNotifier playerNotifier;
  Timer? _mTimer;
  @override
  void initState() {
    super.initState();
    playerNotifier=PlayerNotifier.init();
    widget.controller.addListener(_updateState);
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _settingAnimController =
        AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _changeOpacity =
        Tween(begin: 1.0, end: 0.0).animate(_animationController); //修改透明度
    _changePosition =
        Tween(begin: 0.0, end: -15.0).animate(_animationController);
    _hideWidget();
  }

  _updateState() {
    if (!mounted) return;
    _currentPos = widget.controller.value.position;
    if (_currentPos == _oldPos && widget.controller.value.isPlaying) {
      _equalCount++;
      if (_equalCount > 5 && isPlaying) {
        // showToast('暂停了');
        // debugPrint('player======暂停了');
        isPlaying = false;
        // _showPlay=true;
      }
    } else {
      // debugPrint('player======开始播放');
      _oldPos = _currentPos;
      _equalCount = 0;
      // showToast('开始播放');
      if (!isPlaying) {
        isPlaying = true;
        // _showPlay=false;
      }
    }
    _handler?.onVideoProgress?.call(_currentPos == const Duration(seconds: 0)
        ? '00:00'
        : _processDuration(_currentPos));
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    _mTimer?.cancel();
    super.dispose();
  }

_showWidget() {
    _animationController.reverse();
    playerNotifier.setShowWidget(true);
    _mTimer = Timer(const Duration(seconds: 3), () {
      _hideWidget();
    });
  }

  _hideWidget() {
    _animationController.forward();
    playerNotifier.setShowWidget(false);
  }

  _buildTopButtons() {
    WindController windController = WindController.of(context);
    return SafeArea(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
              opacity: _changeOpacity.value,
              child: Transform.translate(
                  offset: Offset(0.0, _changePosition.value),
                  child: Container(
                    margin: EdgeInsets.only(left:windController.isFullScreen?32:10,right:windController.isFullScreen?32:10,top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            WindButton(
                                onPressed: () {
                                  debugPrint(
                                      'wind============onBackClick icon_back');
                                  bool _isFullScreen =
                                      MediaQuery.of(context).orientation ==
                                          Orientation.landscape;
                                  if (_isFullScreen) {
                                    windController.toggleFullScreen();
                                  } else {
                                    widget.onBackClick?.call();
                                    _handler?.onBackClick?.call();
                                  }
                                },
                                child: buildImage('icon_back',width: 25,height:25,padding: EdgeInsets.all(0))),
                            Container(
                                child: Text(widget.title,
                                    style: const TextStyle(
                                        color: ColorUtils.mainColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)))
                          ],
                        ),
                        Row(
                          children: [
                            windController.isFullScreen?
                            WindButton(
                              onPressed: () {
                                _handler?.onCollectClick?.call();
                              },
                              child: buildImage('icon_star',margin:const EdgeInsets.only(right: 10)),
                            ):const SizedBox(),
                            // Container(
                            //   color: Colors.red,
                            // )
                            WindButton(
                              onPressed: () {
                                _handler?.onShareClick?.call();
                              },
                              child: buildImage('icon_share'),
                            ),
                            windController.isFullScreen?
                            WindButton(
                              onPressed: () {
                                _handler?.onShareClick?.call();
                              },
                              child: buildImage('icon_setting',margin:const EdgeInsets.only(left: 10)),
                            ):const SizedBox()
                          ],
                        )
                      ],
                    ),
                  )));
        },
      ),
    );
  }

  _buildBottomButtons() {
    WindController windController = WindController.of(context);
    var duration = _processDuration(widget.controller.value.duration);
    var position =
        _currentPos == null ? '00:00' : _processDuration(_currentPos);
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _changeOpacity.value,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal:windController.isFullScreen?32:16),
              margin: EdgeInsets.only(bottom: windController.isFullScreen?20:5),
              height: widget.bottomHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(position,
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: VideoProgressBar(
                      widget.controller,
                      barHeight: 6,
                      handleHeight: 6,
                      drawShadow: false,
                    ),
                  )),
                  Text(
                    duration,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Row(
                    children: [
                      windController.allowPip?
                      WindButton(
                        onPressed: () {
                          _handler?.onPipClick?.call();
                        },
                        child: buildImage('icon_pip'),
                      ):const SizedBox(),
                      WindButton(
                          onPressed: () {
                            _handler?.onRotateScreenClick
                                ?.call(windController.isFullScreen);
                            windController
                                .toggleFullScreen(); //设置controller中isFullScreen状态
                          },
                          child: buildImage('icon_rotate_screen_v',padding: const EdgeInsets.only(left: 5,top: 5,bottom: 5)))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  _buildSubtitles() {
    return Container(
      child: Text(
        widget.subTitle,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  _buildPlayButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _changeOpacity.value,
            child: WindButton(
                onPressed: () {
                  var controller = widget.controller;
                  _handler?.onPlayClick?.call(controller.value.isPlaying);
                  if (controller.value.isPlaying) {
                    controller.pause();
                    _showWidget();
                  } else {
                    controller.play();
                    _hideWidget();
                  }
                },
                child: widget.controller.value.isPlaying && isPlaying
                    ? buildImage('icon_video_pause')
                    : buildImage('icon_video_play.jpg', isPNG: false)),
          );
        },
      ),
    );
  }
  _buildLockButton() {
    playerNotifier=Provider.of<PlayerNotifier>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: WindButton(
              onPressed: () {
                if(playerNotifier.isLocked){
                  playerNotifier.setLocked(false);
                  _showWidget();
                }else{
                  playerNotifier.setLocked(true);
                  _hideWidget();
                }
              },
              child: buildImage(playerNotifier.isLocked?'icon_screen_locked':'icon_screen_unlocked',
                  width: 50, height: 50, padding: EdgeInsets.zero)),
        )
      ],
    );
  }

  _processDuration(Duration duration) {
    var _duration = duration.toString();
    var index = _duration.indexOf('.');
    var colonIndex = _duration.indexOf(":");
    if (index != -1) {
      _duration = _duration.substring(0, index);
    }
    // debugPrint('duration=${duration.toString()},index=$index,_duration=$_duration');
    if (colonIndex == 1) {
      var first = _duration.substring(0, 1);
      // print('first=$first,,${first=='0'}');
      if (first == '0') {
        _duration = _duration.substring(2, _duration.length);
      } else {
        _duration = '0$_duration';
      }
    } else {
      _duration = '0$_duration';
    }
    return _duration;
  }

  @override
  Widget build(BuildContext context) {
    WindController windController = WindController.of(context);
    playerNotifier = Provider.of<PlayerNotifier>(context);
    return GestureDetector(
        onTap: () {
          if (playerNotifier.isLocked) return;
          if (playerNotifier.showWidget) {
            _hideWidget();
          } else {
            _showWidget();
          }
        },
        onHorizontalDragDown: (v) {},
        onHorizontalDragUpdate: (v) {},
        onHorizontalDragCancel: () {},
        onHorizontalDragStart: (v) {},
        onHorizontalDragEnd: (v) {},
        onVerticalDragDown: (v) {},
        onVerticalDragUpdate: (v) {
          var screenWidth = MediaQuery.of(context).size.width;
          var dy = v.delta.dy;
          var dx = v.localPosition.dx;
          if (dx < screenWidth / 2) {
            playerNotifier.setBrightnessProgress(dy);
          } else {
            playerNotifier.setVolumeProgress(dy);
          }
        },
        onVerticalDragCancel: () {},
        onVerticalDragStart: (v) {},
        onVerticalDragEnd: (v) {
          debugPrint('wind============onVerticalDragEnd');
          playerNotifier.setShowVolumeProgress(false);
          playerNotifier.setShowBrightnessProgress(false);
          setState(() {});
        },
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButtons(),
                  Container(
                    // color: Colors.yellowAccent,
                    child: Column(
                      children: [_buildSubtitles(), _buildBottomButtons()],
                    ),
                  ),
                ],
              ),
              _buildPlayButton(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  windController.isFullScreen
                      ? _buildLockButton()
                      : const SizedBox(),
                ],
              ),
              playerNotifier.showVolumeProgress
                  ? _buildVolumeProgress(playerNotifier: playerNotifier)
                  : const SizedBox(),
              playerNotifier.showBrightnessProgress
                  ? _buildBrightnessProgress(playerNotifier: playerNotifier)
                  : const SizedBox(),
            ],
          ),
        ));
  }
}

class _buildBrightnessProgress extends StatelessWidget {
  const _buildBrightnessProgress({
    Key? key,
    required this.playerNotifier,
  }) : super(key: key);

  final PlayerNotifier playerNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
              color: const Color(0xe0000000),
              borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildImage('icon_brightness'),
              LinearPercentIndicator(
                width: 140,
                progressColor:const Color(0xffFFECC8),
                percent: playerNotifier.brightnessProgress,
                barRadius: const Radius.circular(5),
              )
            ],
          ),
        ));
  }
}

class _buildVolumeProgress extends StatelessWidget {
  const _buildVolumeProgress({
    Key? key,
    required this.playerNotifier,
  }) : super(key: key);

  final PlayerNotifier playerNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
              color: const Color(0xe0000000),
              borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildImage('icon_volume'),
              LinearPercentIndicator(
                width: 140,
                progressColor:const Color(0xffFFECC8),
                percent: playerNotifier.volumeProgress,
                barRadius: const Radius.circular(5),
              )
            ],
          ),
        ));
  }
}
