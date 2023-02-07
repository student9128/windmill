library windmill;
export 'src/wind_video_player.dart';
export 'src/wind_controller.dart';
export 'src/wind_live_controller.dart';
export 'src/wind_live_player.dart';
export 'src/abs_event_handler.dart';
export 'src/action_event_handler.dart';
export 'src/abs_event_handler_impl.dart';
export 'src/agora_action_event_handler.dart';
import 'dart:async';

import 'package:flutter/services.dart';
//
// class Windmill {
//   static const MethodChannel _channel = MethodChannel('windmill');
//
//   static Future<String?> get platformVersion async {
//     final String? version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }
