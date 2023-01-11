import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:windmill/src/abs_event_handler_impl.dart';
import 'package:windmill/src/wind_video_player.dart';
typedef WindRoutePageBuilder = Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    WindControllerProvider controllerProvider
    );
class WindController extends ChangeNotifier{
  final VideoPlayerController videoPlayerController;
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
  final bool allowPip;
  final Duration? startPos;
  final bool fullScreenByDefault;
  final WindRoutePageBuilder? routePageBuilder;
  /// Defines the system overlays visible on entering fullscreen
  final List<SystemUiOverlay>? systemOverlaysOnEnterFullScreen;

  /// Defines the set of allowed device orientations on entering fullscreen
  final List<DeviceOrientation>? deviceOrientationsOnEnterFullScreen;

  /// Defines the system overlays visible after exiting fullscreen
  final List<SystemUiOverlay> systemOverlaysAfterFullScreen;

  /// Defines the set of allowed device orientations after exiting fullscreen
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  bool _isFullScreen = false;
  bool get isFullScreen =>_isFullScreen;
  bool get isPlaying => videoPlayerController.value.isPlaying;

  WindController({
    required this.videoPlayerController,
    this.playbackSpeeds = const [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2],
    this.autoInitialize=false,
    this.autoPlay=false,
    this.looping=false,
    this.showControls=true,
    this.showControlsOnInitialize=true,
    this.aspectRatio,
    this.allowFullScreen=true,
    this.allowMuting=false,
    this.allowPlaybackSpeedChanging= true,
    this.allowPip=false,
    this.startPos,
    this.fullScreenByDefault=false,
    this.routePageBuilder,
    this.systemOverlaysOnEnterFullScreen,
    this.deviceOrientationsOnEnterFullScreen,
    this.systemOverlaysAfterFullScreen = SystemUiOverlay.values,
    this.deviceOrientationsAfterFullScreen = DeviceOrientation.values,
  }) : assert(playbackSpeeds.every((speed) => speed > 0)) {
    _initialize();
  }

  static WindController of(BuildContext context){
    final provider = context.dependOnInheritedWidgetOfExactType<WindControllerProvider>()!;
    return provider.controller;
  }
  Future _initialize() async{
    await videoPlayerController.setLooping(looping);
    if(autoInitialize||autoPlay&&!videoPlayerController.value.isInitialized){
    await videoPlayerController.initialize();
    }
    if(autoPlay){
      if(fullScreenByDefault){enterFullScreen();}
      await videoPlayerController.play();
    }
    if(startPos!=null){
      await videoPlayerController.seekTo(startPos!);
    }
  }
  void enterFullScreen(){
    _isFullScreen = true;
    notifyListeners();
  }
  void exitFullScreen(){
    _isFullScreen= false;
    notifyListeners();
  }
  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  Future<void> play() async {
    await videoPlayerController.play();
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setLooping(bool looping) async {
    await videoPlayerController.setLooping(looping);
  }

  Future<void> pause() async {
    await videoPlayerController.pause();
  }

  Future<void> seekTo(Duration moment) async {
    await videoPlayerController.seekTo(moment);
  }

  Future<void> setVolume(double volume) async {
    await videoPlayerController.setVolume(volume);
  }
  Future<AbsEventHandlerImpl> createActionEvent() async {
    return AbsEventHandlerImpl.instance;
  }
}
