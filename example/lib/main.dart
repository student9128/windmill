import 'package:flutter/material.dart';
import 'dart:async';
import 'package:windmill/windmill.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
void main() {
  runApp(MaterialContainer());
}
class MaterialContainer extends StatelessWidget{
  const MaterialContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: MyApp(),
   );
  }

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  WindController? windController;
  WindLiveController? windLiveController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initVideoPlayer();

  }
  initVideoPlayer() async{
    Map<Permission, PermissionStatus> statuses=await [Permission.camera,Permission.audio].request();
    String src='';
    videoPlayerController = VideoPlayerController.network(src,videoPlayerOptions:VideoPlayerOptions(allowBackgroundPlayback: true));
    await videoPlayerController.initialize();
    windController = WindController(videoPlayerController: videoPlayerController,autoPlay: true,looping: true,allowPip: true);
    // windLiveController = WindLiveController();
    AbsEventHandlerImpl? actionEvent =await windController?.createActionEvent();
    actionEvent?.setActionEventHandler(ActionEventHandler(
      onBackClick: (){
        debugPrint('x=======onBackClick');
      },
        onCollectClick: (){
          debugPrint('x=======onCollectClick');
        },
      onShareClick: (){
        debugPrint('x=======onShareClick');
      },
      onPipClick:(){
        debugPrint('x=======onPipClick');
      },
      onSettingClick: (){
        debugPrint('x=======onSettingClick');
      },
      onVideoProgress: (currentPosition){
        // debugPrint('x=======onVideoProgress====$currentPosition');
      },
      onPlayClick: (isPlaying){
        debugPrint('x=======onPlayClick=isPlaying=$isPlaying');
      }
    ));
    setState(() {

    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // String platformVersion;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // // We also handle the message potentially returning null.
    // try {
    //   platformVersion =
    //       await Windmill.platformVersion ?? 'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            // Text('Running on: $_platformVersion\n'),
            Row(
              children: [
                ElevatedButton(onPressed: (){
                  videoPlayerController.play();
                }, child: Text('播放')),
                ElevatedButton(onPressed: (){
                  videoPlayerController.pause();
                }, child: Text('暂停')),
                ElevatedButton(onPressed: (){
                  windController?.toggleFullScreen();
                }, child: Text('全屏'))
              ],
            )
           ,
            windController!=null&&windController!.videoPlayerController.value.isInitialized?
                Container(
                  color: Colors.red,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width/1.77,
                  child:Center(
                    child: WindVideoPlayer(controller: windController!,needRefresh: (){
                      debugPrint('wind=========windVideo needRefresh');
                      // setState(() {
                      //
                      // });
                    },subtitle: 'hello',),
                  ),
                )
           :Container(color: Colors.green,width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width/1.77,),
            // windLiveController!=null?
            // Container(
            //   color: Colors.blue,
            //   width: 500,
            //   height: 280,
            //   child:Center(
            //     child: WindLivePlayer(controller: windLiveController!,),
            //   ),
            // ):Container(color: Colors.yellow,width: 500,
            //   height: 280,)
          ],
        ),
    );
  }
}
