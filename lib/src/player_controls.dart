import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/constant.dart';
import 'package:windmill/src/linear_percent_indicator.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/progress_bar.dart';
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
    with TickerProviderStateMixin,WidgetsBindingObserver {
  late AnimationController _animationController, _settingAnimController,_lockController;
  late Animation _changeOpacity;
  late Animation _changePosition;
  late Animation _subtitlePosition;
  late Animation _lockOpacity;
  final _handler = AbsEventHandlerImpl.instance.mHandler;
  late PlayerNotifier playerNotifier;
  Timer? _mTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    playerNotifier=PlayerNotifier.init();
    widget.controller.addListener(_updateState);
    _animationController =AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _lockController =AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _settingAnimController =
        AnimationController(duration: const Duration(milliseconds:300), vsync: this);
    _changeOpacity =
        Tween(begin: 1.0, end: 0.0).animate(_animationController); //修改透明度
    _changePosition = Tween(begin: 0.0, end: -15.0).animate(_animationController);
    _subtitlePosition = Tween(begin: 0.0, end: 21.0).animate(_animationController);
     _lockOpacity = Tween(begin: 1.0, end: 0.0).animate(_lockController);
     Future.delayed(const Duration(seconds: 3),(){_hideWidget();});
  }

  _updateState() {
    if (!mounted) return;
    Provider.of<PlayerNotifier>(context,listen: false).updateState(widget.controller);
    _handler?.onVideoProgress?.call(playerNotifier.position);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    _mTimer?.cancel();
    _animationController.dispose();
    _settingAnimController.dispose();
    _lockController.dispose();
    super.dispose();
  }

  _showWidget() {
    _animationController.reverse();
    _lockController.reverse();
    playerNotifier.setShowWidget(true);
    _mTimer = Timer(const Duration(seconds: 3), () {
      _hideWidget();
    });
  }

  _hideWidget() {
    _animationController.forward();
    _lockController.forward();
    playerNotifier.setShowWidget(false);
  }
  _onDragEnd() {
    playerNotifier.progressDragEndX();
  }
  _onDragStart(bool isPlaying) {
    playerNotifier.progressDragStartX(isPlaying: isPlaying);
  }
  _onDragUpdate() {
    // playerNotifier.progressDragUpdateX(x)
  } 
 _buildTopButtons() {
    WindController windController = WindController.of(context);
    return SafeArea(
      left: false,
      right: false,
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
                                  if(playerNotifier.isLocked)return;
                                  bool isFullScreen =
                                      MediaQuery.of(context).orientation ==
                                          Orientation.landscape;
                                  if (isFullScreen) {
                                    windController.exitFullScreen();
                                    widget.onRotateScreenClick?.call(true);
                                  } else {
                                    widget.onBackClick?.call();
                                    _handler?.onBackClick?.call();
                                  }
                                },
                                child: buildImage('icon_back',width: 25,height:25,padding: const EdgeInsets.all(0))),
                            windController.isFullScreen?
                            Text(widget.title,
                                style: const TextStyle(
                                    color: ColorUtils.mainColor,
                                    fontSize: 18,
                                    // ignore: prefer_const_constructors
                                    fontWeight: FontWeight.bold)):SizedBox(),
                          ],
                        ),
                        Row(
                          children: [
                            windController.isFullScreen?
                            WindButton(
                              onPressed: () {
                                if(playerNotifier.isLocked)return;
                                _handler?.onCollectClick?.call();
                                windController.setHasCollected(true);
                              },
                              child: buildImage(windController.hasCollected?'icon_star_selected':'icon_star',margin:const EdgeInsets.only(right: 10)),
                            ):const SizedBox(),
                            // Container(
                            //   color: Colors.red,
                            // )
                            WindButton(
                              onPressed: () {
                                if(playerNotifier.isLocked)return;
                                _handler?.onShareClick?.call();
                              },
                              child: buildImage('icon_share'),
                            ),
                            windController.isFullScreen?
                            WindButton(
                              onPressed: () {
                                if(playerNotifier.isLocked)return;
                                _handler?.onSettingClick?.call();
                                // if(playerNotifier.showSettingModal){
                                //   _hideSettingModal();
                                // }else{

                               _showSettingModal();
                                // }
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
                  Text(playerNotifier.position,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: VideoProgressBar(
                      widget.controller,
                      barHeight: 3,
                      handleHeight: 6,
                      drawShadow: false,
                      onDragStart: _onDragStart,
                      onDragUpdate: _onDragUpdate,
                      onDragEnd: _onDragEnd,
                      progress:Platform.isIOS?playerNotifier.lastDuration:null
                    ),
                  )),
                  Text(
                    playerNotifier.duration,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Row(
                    children: [
                      windController.allowPip?
                      WindButton(
                        onPressed: () {
                          if(playerNotifier.isLocked)return;
                           bool isFullScreen =MediaQuery.of(context).orientation ==Orientation.landscape;
                          if (isFullScreen) {
                            windController.exitFullScreen();
                            widget.onRotateScreenClick?.call(true);
                          }
                          _handler?.onPipClick?.call();
                        },
                        child: buildImage('icon_pip'),
                      ):const SizedBox(),
                      WindButton(
                          onPressed: () {
                            if(playerNotifier.isLocked)return;
                            widget.onRotateScreenClick?.call(windController.isFullScreen);
                            _handler?.onRotateScreenClick?.call(windController.isFullScreen);
                            windController.toggleFullScreen(); //设置controller中isFullScreen状态
                          },
                          child: buildImage(windController.isFullScreen?'icon_rotate_screen_h':'icon_rotate_screen_v',padding: const EdgeInsets.only(left: 5,top: 5,bottom: 5)))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  _buildSubtitles() {
    WindController windController = WindController.of(context);
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0.0, _subtitlePosition.value),
            child:Container(
              padding: EdgeInsets.symmetric(horizontal:windController.isFullScreen?32:16),
              child: Text(
              widget.subTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            ) ,
          );
        });
  }

  _buildPlayButton() {
    return Center(
      child: playerNotifier.showProgress
          ? Platform.isAndroid
              ? const SizedBox(
                width: 16,
                height: 16,
                  child: CircularProgressIndicator(color: ColorUtils.mainColor,strokeWidth: 2,),
                )
              : const CupertinoActivityIndicator(
                  color: ColorUtils.mainColor,
                  radius: 16,
                )
          : AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _changeOpacity.value,
            child: WindButton(
                onPressed: () {
                  if(playerNotifier.isLocked)return;
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
                child: widget.controller.value.isPlaying && playerNotifier.isPlaying
                    ? buildImage('icon_video_pause')
                    : buildImage('icon_video_play.jpg', isPNG: false)),
          );
        },
      ),
    );
  }
 _buildLockButton() {
    playerNotifier = Provider.of<PlayerNotifier>(context);
    return AnimatedBuilder(
        animation: _lockController,
        builder: ((context, child) {
          return Opacity(
            opacity: _lockOpacity.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: WindButton(
                      onPressed: () {
                        if (playerNotifier.isLocked) {
                          _mTimer?.cancel();
                          playerNotifier.setLocked(false);
                          _showWidget();
                        } else {
                          playerNotifier.setLocked(true);
                          _hideWidget();
                        }
                      },
                      child: buildImage(
                          playerNotifier.isLocked
                              ? 'icon_screen_locked'
                              : 'icon_screen_unlocked',
                          width: 50,
                          height: 50,
                          padding: EdgeInsets.zero)),
                )
              ],
            ),
          );
        }));
  }
  _buildPlaySpeedItem(String text, int index, bool isSelected) {
    var width = (MediaQuery.of(context).size.height - 32.0 - 16.0 * 3) / 4;
    List speedList = [1.0, 1.25, 1.5, 2.0];
    return WindButton(
      onPressed: () {
        Constant.currentSeedIndex=index;
        widget.controller.setPlaybackSpeed(speedList[index]);
        playerNotifier.setCurrentSpeedIndex(index);
      },
      child: Container(
          width: width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
              color: ColorUtils.greenGary,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                  color: isSelected ? ColorUtils.yellow : ColorUtils.greenGary,
                  width: 2.0)),
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? ColorUtils.mainColor : ColorUtils.gray),
          )),
    );
  }
  _buildSettingModal() {
    List speedList = ['x1.0', 'x1.25', 'x1.5', 'x2.0'];
    List<Widget> speedWidgets = [];
    for (int i = 0; i < speedList.length; i++) {
      speedWidgets.add(_buildPlaySpeedItem(
          speedList[i], i, Constant.currentSeedIndex == i ? true : false));
    }
    return Container(
      width: MediaQuery.of(context).size.height,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        color: ColorUtils.backgroundColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '播放速度',
            style: TextStyle(color: ColorUtils.gray, fontSize: 12),
            textAlign: TextAlign.left,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: speedWidgets,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: const Text('其他',
                style: TextStyle(color: ColorUtils.gray, fontSize: 12)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('后台播放',
                  style: TextStyle(
                      color: ColorUtils.mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text('关',
                      style: TextStyle(
                          color: playerNotifier.allowBackgroundPlay
                              ? ColorUtils.gray
                              : ColorUtils.mainColor,
                          fontSize: 12)),
                  CupertinoSwitch(
                    value: Constant.allowBackgroundPlay,
                    activeColor: ColorUtils.green,
                    onChanged: (value) {
                      Constant.allowBackgroundPlay=value;
                      WindController.of(context).setEnablePlayBackground(value);
                      playerNotifier.setAllowBackgroundPlay(value);
                      _handler?.onBackgroundPlayClick?.call(value);
                    },
                  ),
                  Text('开',
                      style: TextStyle(
                          color: playerNotifier.allowBackgroundPlay
                              ? ColorUtils.mainColor
                              : ColorUtils.gray,
                          fontSize: 12)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  _showSettingModal() {
    _settingAnimController.forward();
    playerNotifier.setShowSettingModal(true);
  }

  _hideSettingModal() {
    _settingAnimController.reverse();
    playerNotifier.setShowSettingModal(false);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _handler?.onResumed?.call();
        if (!Constant.allowBackgroundPlay &&
            !widget.controller.value.isPlaying) {
          widget.controller.play();
        }

        break;
      case AppLifecycleState.paused:
        _handler?.onPaused?.call();
        if (!Constant.allowBackgroundPlay &&
            widget.controller.value.isPlaying) {
          widget.controller.pause();
        }

        break;
      case AppLifecycleState.inactive:
        _handler?.onInactive?.call();
        break;
      case AppLifecycleState.detached:
        _handler?.onDetached?.call();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    WindController windController = WindController.of(context);
    playerNotifier = Provider.of<PlayerNotifier>(context);
    return GestureDetector(
        onTap: () {
             _mTimer?.cancel();
          if (playerNotifier.isLocked){
             if (playerNotifier.showLockIcon) {//锁屏的时候就动态调整锁屏图标
              _lockController.forward();
              playerNotifier.setShowLockIcon(false);
            } else {
              _lockController.reverse();
              playerNotifier.setShowLockIcon(true);
              _mTimer = Timer(const Duration(seconds: 3), () {
                _lockController.forward();
                playerNotifier.setShowLockIcon(false);
              });
            }
            return;
          } 
          if (playerNotifier.showSettingModal) {
            //
            _hideSettingModal();
            return;
          }
          if (playerNotifier.showWidget) {
            _hideWidget();
          } else {
            _showWidget();
          }
        },
        onHorizontalDragDown: (v) {},
        onHorizontalDragUpdate: (v) {
          if (playerNotifier.isLocked||!windController.enableGesture) return;
          var currentPos = widget.controller.value.position;
          var dx = v.delta.dx;
          currentPos += widget.controller.value.duration * (dx / 1000);
          widget.controller.seekTo(currentPos);
        },
        onHorizontalDragCancel: () {},
        onHorizontalDragStart: (v) {
          if (playerNotifier.isLocked||!windController.enableGesture) return;
          var isPlaying=widget.controller.value.isPlaying;
          if(isPlaying)widget.controller.pause();
          playerNotifier.progressDragStartX(isPlaying: isPlaying);
        },
        onHorizontalDragEnd: (v) {
          if (playerNotifier.isLocked||!windController.enableGesture) return;
          playerNotifier.progressDragEndX();
          if(playerNotifier.isPlayingWhenDragStart)widget.controller.play();
        },
        onVerticalDragDown: (v) {},
        onVerticalDragUpdate: (v) {
          if(playerNotifier.isLocked||!windController.enableGesture)return;
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
          if(playerNotifier.isLocked||!windController.enableGesture)return;
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
                  Column(
                    children: [_buildSubtitles(), _buildBottomButtons()],
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
                  ? VolumeProgress(playerNotifier: playerNotifier)
                  : const SizedBox(),
              playerNotifier.showBrightnessProgress
                  ? BrightnessProgress(playerNotifier: playerNotifier)
                  : const SizedBox(),
                  Positioned(
                    right:0,
                    bottom:0,
                    child:  LayoutBuilder(builder:((context, constraints) {
                 final offsetAnimation =Tween<Offset>(begin:const Offset(1,0), end:const Offset(0,0))
                  .animate(_settingAnimController);
                 return SlideTransition(position: offsetAnimation,
                 child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                 child: _buildSettingModal(),),);
               })))
              
            ],
          ),
        ));
  }
}

class BrightnessProgress extends StatelessWidget {
  const BrightnessProgress({
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

class VolumeProgress extends StatelessWidget {
  const VolumeProgress({
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
