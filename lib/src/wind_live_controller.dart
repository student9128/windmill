import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windmill/src/abs_event_handler_impl.dart';
import 'package:windmill/src/agora_action_event_handler.dart';
import 'package:windmill/src/constant.dart';
import 'package:windmill/src/wind_live_player.dart';

typedef WindLiveRoutePageBuilder = Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    WindLiveControllerProvider controllerProvider);

class WindLiveController extends ChangeNotifier {
  final String appId;
  final String token;
  final String channelName;
  final int optionalUid;
  final bool autoInitialize;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool showControlsOnInitialize;
  final double? aspectRatio;
  final bool allowFullScreen;
  final bool allowMuting;
  final bool allowPlaybackSpeedChanging;
  final bool allowPip;
  ///设置直播清晰度，默认显示该设置项
  final bool enableDefinition;
  final Duration? startPos;
  final bool fullScreenByDefault;
  final WindLiveRoutePageBuilder? routePageBuilder;

  /// Defines the system overlays visible on entering fullscreen
  final List<SystemUiOverlay>? systemOverlaysOnEnterFullScreen;

  /// Defines the set of allowed device orientations on entering fullscreen
  final List<DeviceOrientation>? deviceOrientationsOnEnterFullScreen;

  /// Defines the system overlays visible after exiting fullscreen
  final List<SystemUiOverlay> systemOverlaysAfterFullScreen;

  /// Defines the set of allowed device orientations after exiting fullscreen
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  bool _isFullScreen = false;

  bool get isFullScreen => _isFullScreen;

  int _remoteUid = -1;

  int get remoteUid => _remoteUid;

  String _channelName = "";

  String get channelId => _channelName;

  // bool get isPlaying => videoPlayerController.value.isPlaying;

  WindLiveController({
    required this.appId,
    required this.token,
    required this.channelName,
    required this.optionalUid,
    this.autoInitialize = false,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.showControlsOnInitialize = true,
    this.aspectRatio,
    this.allowFullScreen = true,
    this.allowMuting = false,
    this.allowPlaybackSpeedChanging = true,
    this.allowPip = false,
    this.enableDefinition=true,
    this.startPos,
    this.fullScreenByDefault = false,
    this.routePageBuilder,
    this.systemOverlaysOnEnterFullScreen,
    this.deviceOrientationsOnEnterFullScreen,
    this.systemOverlaysAfterFullScreen = SystemUiOverlay.values,
    this.deviceOrientationsAfterFullScreen = DeviceOrientation.values,
  }) : assert(appId.isNotEmpty) {
    // _initialize();
  }

  static WindLiveController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<WindLiveControllerProvider>()!;
    return provider.controller;
  }

  bool _isInit = false;

  bool get isInit => _isInit;
  late RtcEngine _engine;

  RtcEngine get engine => _engine;
  AgoraActionEventHandler? _agoraHandler;

  Future _initialize() async {
    _agoraHandler = AbsEventHandlerImpl.instance.mAgoraHandler;
    RtcEngineContext context = RtcEngineContext(appId);
    _engine = await RtcEngine.createWithContext(context);
    _isInit = true;
    await _addListener(_engine);
    joinChannel();
  }
  void initAgora(){
    _initialize();
  }

  void joinChannel() async {
    await _engine.enableVideo();
    await _engine.enableLocalAudio(false);
    await _engine.enableLocalVideo(false);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Audience);
    await _engine.joinChannel(token, channelName, null, optionalUid);
    setChannelId(channelName);
  }

  _addListener(RtcEngine engine) {
    engine.setEventHandler(RtcEngineEventHandler(warning: (warningCode) {
      _agoraHandler?.warning?.call(warningCode);
    }, error: (errorCode) {
      _agoraHandler?.error?.call(errorCode);
    }, joinChannelSuccess: (channel, uid, elapsed) {
      _agoraHandler?.joinChannelSuccess?.call(channel, uid, elapsed);
    }, userJoined: (uid, elapsed) {
      _agoraHandler?.userJoined?.call(uid, elapsed);
      _engine.setRemoteVideoStreamType(uid, VideoStreamType.Low);
      setRemoteUid(uid);
    }, userOffline: (uid, reason) {
      _agoraHandler?.userOffline?.call(uid, reason);
      // setRemoteUid(-1);
    }, firstRemoteVideoFrame: (int uid, int width, int height, int elapsed) {
      _agoraHandler?.firstRemoteVideoFrame?.call(uid, width, height, elapsed);
    }, leaveChannel: (stats) {
      _agoraHandler?.leaveChannel?.call(stats);
    }, remoteVideoStateChanged: (int uid, VideoRemoteState state,
        VideoRemoteStateReason reason, int elapsed) {
      _agoraHandler?.remoteVideoStateChanged?.call(uid, state, reason, elapsed);
    }));
  }

  void refresh() async {
    await _engine.leaveChannel();
    await _engine.joinChannel(token, channelName, null, optionalUid);
  }

  void setChannelId(String channelId) {
    _channelName = channelId;
    notifyListeners();
  }

  void setRemoteUid(int uid) {
    _remoteUid = uid;
    notifyListeners();
  }

  Future leaveChannel() async{
    await _engine.leaveChannel();
    await _engine.destroy();
  }

  void switchChannel() async{
    await _engine.leaveChannel();
    _engine.joinChannel(token, channelName, null, optionalUid);
  }
  void setLiveVideoStreamType(int index){
    _engine.setRemoteVideoStreamType(_remoteUid,index==0?VideoStreamType.High:VideoStreamType.Low);
  }

  void muteAllRemoteAudioStreams(bool b){
    _engine.muteAllRemoteAudioStreams(b);
  }

  void enterFullScreen() {
    _isFullScreen = true;
    notifyListeners();
  }

  void exitFullScreen() {
    _isFullScreen = false;
    notifyListeners();
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }
  bool _hasCollected = false;
  bool get hasCollected => _hasCollected;
  void setHasCollected(bool b) {
    if (_hasCollected == b) return;
    _hasCollected = b;
    notifyListeners();
  }

  bool _enableGesture = true;
  bool get enableGesture => _enableGesture;
  void setEnableGesture(bool b) {
    if (_enableGesture == b) return;
    _enableGesture = b;
    notifyListeners();
  }

  bool _enablePlayBackground = true;
  bool get enablePlayBackground => _enablePlayBackground;
  void setEnablePlayBackground(bool b) {
    if (_enablePlayBackground == b) return;
    Constant.allowBackgroundPlay=b;
    _enablePlayBackground = b;
    notifyListeners();
  }

  bool _enableWakeScreen = true;
  bool get enableWakeScreen => _enableWakeScreen;
  void setEnableWakeScreen(bool b) {
    if (_enableWakeScreen == b) return;
    _enableWakeScreen = b;
    notifyListeners();
  }

  Future<AbsEventHandlerImpl> createActionEvent() async {
    return AbsEventHandlerImpl.instance;
  }

  Future<AbsEventHandlerImpl> createAgoraActionEvent() async {
    return AbsEventHandlerImpl.instance;
  }
}
