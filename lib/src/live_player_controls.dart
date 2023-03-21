import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:windmill/src/constant.dart';
import 'package:windmill/src/linear_percent_indicator.dart';
import 'package:windmill/src/player_notifier.dart';
import 'package:windmill/src/util/color_utils.dart';
import 'package:windmill/src/util/widget_utils.dart';
import 'package:windmill/src/util/wind_button.dart';
import 'package:windmill/windmill.dart';

class LivePlayerControls extends StatefulWidget {

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

  const LivePlayerControls(
      {Key? key,
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
  State<LivePlayerControls> createState() => _LivePlayerControlsState();
}

class _LivePlayerControlsState extends State<LivePlayerControls>
    with TickerProviderStateMixin,WidgetsBindingObserver {
  late AnimationController _animationController, _settingAnimController,_lockController;
  late Animation _changeOpacity;
  late Animation _changePosition;
  late Animation _lockOpacity;
  bool isPlaying = true;
  final _handler = AbsEventHandlerImpl.instance.mHandler;
  late PlayerNotifier playerNotifier;
  Timer? _mTimer;

  @override
  void initState() {
    super.initState();
    Constant.currentSeedIndex=1;
    WidgetsBinding.instance.addObserver(this);
    playerNotifier=PlayerNotifier.init();
    _animationController =AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _lockController =AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _settingAnimController =
        AnimationController(duration: const Duration(milliseconds:300), vsync: this);
    _changeOpacity =
        Tween(begin: 1.0, end: 0.0).animate(_animationController); //修改透明度
    _changePosition =
        Tween(begin: 0.0, end: -15.0).animate(_animationController);
    _lockOpacity = Tween(begin: 1.0, end: 0.0).animate(_lockController);
    _hideWidget();
  }


  @override
  void dispose() {
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

  _buildTopButtons() {
    WindLiveController windLiveController = WindLiveController.of(context);
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
                    margin: EdgeInsets.only(left:windLiveController.isFullScreen?32:10,right:windLiveController.isFullScreen?32:10,top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            WindButton(
                                onPressed: () {
                                  if (playerNotifier.isLocked) return;
                                  bool isFullScreen =
                                      MediaQuery.of(context).orientation ==
                                          Orientation.landscape;
                                  if (isFullScreen) {
                                    windLiveController.toggleFullScreen();
                                    _handler?.onRotateScreenClick?.call(true);
                                  } else {
                                    widget.onBackClick?.call();
                                    _handler?.onBackClick?.call();
                                  }
                                },
                                child: buildImage('icon_back',
                                    width: 25,
                                    height: 25,
                                    padding: const EdgeInsets.all(0))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Text(
                                '直播中',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            windLiveController.isFullScreen?
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                                child: Text(widget.title,
                                    style: const TextStyle(
                                        color: ColorUtils.mainColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold))):const SizedBox()
                          ],
                        ),
                        Row(
                          children: [
                            windLiveController.isFullScreen?
                            WindButton(
                              onPressed: () {
                                if(playerNotifier.isLocked)return;
                                _handler?.onCollectClick?.call();
                              },
                              child: buildImage(windLiveController.hasCollected?'icon_star_selected':'icon_star',margin:const EdgeInsets.only(right: 10)),
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
                            windLiveController.isFullScreen?
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
    WindLiveController windLiveController = WindLiveController.of(context);
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _changeOpacity.value,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal:windLiveController.isFullScreen?32:16),
              margin: EdgeInsets.only(bottom: windLiveController.isFullScreen?20:5),
              height: widget.bottomHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  windLiveController.allowPip?
                      WindButton(
                        onPressed: () {
                          if(playerNotifier.isLocked)return;
                          _handler?.onPipClick?.call();
                        },
                        child: buildImage('icon_pip'),
                      ):const SizedBox(),
                      WindButton(
                          onPressed: () {
                            if(playerNotifier.isLocked)return;
                            _handler?.onRotateScreenClick
                                ?.call(windLiveController.isFullScreen);
                            windLiveController
                                .toggleFullScreen(); //设置controller中isFullScreen状态
                          },
                          child: buildImage(windLiveController.isFullScreen?'icon_rotate_screen_h':'icon_rotate_screen_v',padding: const EdgeInsets.only(left: 5,top: 5,bottom: 5)))
                ],
              ),
            ),
          );
        });
  }

  _buildSubtitles() {
    return Text(
      widget.subTitle,
      style: const TextStyle(color: Colors.white),
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
                  if(playerNotifier.isLocked)return;
                  _handler?.onRefreshClick?.call();
                    _hideWidget();
                },
                child: buildImage('icon_refresh',width: 30,height: 30)),
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
    return WindButton(
      onPressed: () {
        Constant.currentSeedIndex=index;
        _handler?.onVideoStreamTypeClick?.call(index);
        playerNotifier.setCurrentSpeedIndex(index);
      },
      child: Container(
          width: width,
          margin: const EdgeInsets.only(left: 16.0),
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
    List speedList = ['高清', '流畅'];
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
            '清晰度',
            style: TextStyle(color: ColorUtils.gray, fontSize: 12),
            textAlign: TextAlign.left,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                      WindLiveController.of(context).setEnablePlayBackground(value);
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
        _handler?.onResumed;
        if (!Constant.allowBackgroundPlay) {
          WindLiveController windLiveController =
              WindLiveController.of(context);
          windLiveController.muteAllRemoteAudioStreams(false);
        }

        break;
      case AppLifecycleState.paused:
        _handler?.onPaused;
        if (!Constant.allowBackgroundPlay) {
          WindLiveController windLiveController =
              WindLiveController.of(context);
          windLiveController.muteAllRemoteAudioStreams(true);
        }
        break;
      case AppLifecycleState.inactive:
        _handler?.onInactive;
        break;
      case AppLifecycleState.detached:
        _handler?.onDetached;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    WindLiveController windController = WindLiveController.of(context);
    playerNotifier = Provider.of<PlayerNotifier>(context);
    return GestureDetector(
        onTap: () {
          if (playerNotifier.isLocked) {
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
        onHorizontalDragUpdate: (v) {},
        onHorizontalDragCancel: () {},
        onHorizontalDragStart: (v) {},
        onHorizontalDragEnd: (v) {},
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
