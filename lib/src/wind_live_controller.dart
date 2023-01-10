import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/wind_live_player.dart';
import 'package:windmill/src/wind_video_player.dart';

typedef WindLiveRoutePageBuilder = Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    WindLiveControllerProvider controllerProvider);

class WindLiveController extends ChangeNotifier {
  final List<double> playbackSpeeds;
  final bool autoInitialize;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool showControlsOnInitialize;
  final double? aspectRatio;
  final bool allowFullScreen;
  final bool allowMuting;
  final bool allowPlaybackSpeedChanging;
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

  // bool get isPlaying => videoPlayerController.value.isPlaying;

  WindLiveController({
    this.playbackSpeeds = const [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2],
    this.autoInitialize = false,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.showControlsOnInitialize = true,
    this.aspectRatio,
    this.allowFullScreen = true,
    this.allowMuting = false,
    this.allowPlaybackSpeedChanging = true,
    this.startPos,
    this.fullScreenByDefault = false,
    this.routePageBuilder,
    this.systemOverlaysOnEnterFullScreen,
    this.deviceOrientationsOnEnterFullScreen,
    this.systemOverlaysAfterFullScreen = SystemUiOverlay.values,
    this.deviceOrientationsAfterFullScreen = DeviceOrientation.values,
  }) : assert(playbackSpeeds.every((speed) => speed > 0)) {
    _initialize();
  }

  static WindLiveController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<WindLiveControllerProvider>()!;
    return provider.controller;
  }
  late RtcEngine _engine;
  Future _initialize() async {
    // await videoPlayerController.setLooping(looping);
    // if(autoInitialize||autoPlay&&!videoPlayerController.value.isInitialized){
    // await videoPlayerController.initialize();
    // }
    // if(autoPlay){
    //   if(fullScreenByDefault){enterFullScreen();}
    //   await videoPlayerController.play();
    // }
    // if(startPos!=null){
    //   await videoPlayerController.seekTo(startPos!);
    // }
    String appIdx = 'd4d4713353494ff5b93fca5ec5169f9b';
    String token ='007eJxTYNikJN0XwhOa78GvF+E2oeO/9+Pq3xlMm5h3zv0aqrdJbbkCQ4pJiom5obGxqbGJpUlammmSpXFacqJparKpoZllmmVSS9CC5IZARoa7qywZGRkgEMTnYQhxDQ6Jd/Zw9PNz9WFgAACmkh/l';
    RtcEngineContext context = RtcEngineContext(appIdx);
    _engine = await RtcEngine.createWithContext(context);
    _addListener(_engine);
    await _engine.enableVideo();
    await _engine.enableLocalAudio(true);
    await _engine.enableLocalVideo(true);
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.joinChannel(token, 'TEST_CHANNEL', null, 0);
  }

  _addListener(RtcEngine engine) {
    engine.setEventHandler(RtcEngineEventHandler(
        warning: (warningCode) {
          debugPrint('liveVideo========joinChange=warningCode=$warningCode');
        },
        error: (errorCode) {
          debugPrint('liveVideo========joinChange=error=$errorCode');
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          debugPrint(
              'liveVideo========joinChange==success==channel=$channel,uid=$uid,elapsed=$elapsed');
        },
        userJoined: (uid, elapsed) {
          debugPrint('liveVideo========joinChange=userJoined=$uid');
        },
        userOffline: (uid, reason) {
          debugPrint('liveVideo========userOffline,reason=$reason');
        },
        leaveChannel: (stats) {},
        remoteVideoStateChanged: (int uid, VideoRemoteState state,
            VideoRemoteStateReason reason, int elapsed) {
          debugPrint(
              'liveVideo=$uid,state=$state,reason=$reason,elapsed=$elapsed}');
        }));
  }

  void refresh() async{
    debugPrint('wind=========windLiveVideo refresh');
    await _engine.leaveChannel();
    await _engine.destroy();
    // String token ='007eJxTYNikJN0XwhOa78GvF+E2oeO/9+Pq3xlMm5h3zv0aqrdJbbkCQ4pJiom5obGxqbGJpUlammmSpXFacqJparKpoZllmmVSS9CC5IZARoa7qywZGRkgEMTnYQhxDQ6Jd/Zw9PNz9WFgAACmkh/l';
    // await _engine.joinChannel(token, 'TEST_CHANNEL', null, 0);
    _initialize();
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
}
