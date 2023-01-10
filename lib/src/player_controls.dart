import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/progress_bar.dart';
import 'package:windmill/src/util/asset_utils.dart';
import 'package:windmill/src/util/color_utils.dart';
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

  // ActionEventHandler? _handler;
  // @override
  // void setActionEventHandler(ActionEventHandler handler) {
  //   _handler = handler;
  // }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _settingAnimController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _changeOpacity =
        Tween(begin: 1.0, end: 0.0).animate(_animationController); //修改透明度
    _changePosition =
        Tween(begin: 0.0, end: -15.0).animate(_animationController);
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
    _handler?.onVideoProgress?.call(_currentPos==const Duration(seconds: 0)?'00:00':_processDuration(_currentPos));
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  Widget _buildImage(String iconName,{bool isPNG=true}){
    return Image.asset(isPNG?AssetUtils.getAssetImagePNG(iconName):AssetUtils.getAssetImage(iconName),
    width: 24,
    height: 24,
    package:'windmill',);
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                  debugPrint(
                                      'wind============onBackClick icon_back');
                                  var x = windController.isPlaying;
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
                              child: _buildImage('icon_back')
                            ),
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
                            IconButton(
                                onPressed: () {
                                  _handler?.onCollectClick?.call();
                                }, icon: _buildImage('icon_star'),
                              ),
                            // Container(
                            //   color: Colors.red,
                            // )
                            IconButton(
                                onPressed: () {
                                  _handler?.onShareClick?.call();
                                },
                                icon:_buildImage('icon_share'),),
                               IconButton(
                                onPressed: () {
                                  _handler?.onShareClick?.call();
                                },
                                icon:_buildImage('icon_setting'),)
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: widget.bottomHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(position,
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
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
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _handler?.onPipClick?.call();
                        },
                        icon: _buildImage('icon_pip'),
                      ),
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _handler?.onRotateScreenClick
                                ?.call(windController.isFullScreen);
                            windController.toggleFullScreen();//设置controller中isFullScreen状态
                          },
                          icon: _buildImage('icon_rotate_screen_v'))
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
      child: Container(
        child: IconButton(
            onPressed: () {
              var controller = widget.controller;
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            icon: widget.controller.value.isPlaying && isPlaying
                  ? _buildImage('icon_video_pause')
                  : _buildImage('icon_video_play.jpg',isPNG: false)),
      ),
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
    // return Container(
    //   width: MediaQuery.of(context).size.width,
    //   height: MediaQuery.of(context).size.height,
    //   // color: Colors.amber,
    // child: Stack(
    //
    //   children: [Positioned(
    // bottom: 100,
    // left: 0,
    // child: Container(child: Text('d12222222'),color: Colors.deepOrangeAccent,),),
    //   Positioned(child: Container(color: Colors.green,width: 10,height: 10,))],
    // ),);
    return Container(
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
              )
            ],
          ),
          _buildPlayButton()
        ],
      ),
    );
  }
}
