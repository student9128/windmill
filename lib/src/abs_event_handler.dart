import 'package:windmill/src/action_event_handler.dart';
import 'package:windmill/src/agora_action_event_handler.dart';

abstract class AbsEventHandler {
  void setActionEventHandler(ActionEventHandler handler);
  void setAgoraActionEventHandler(AgoraActionEventHandler handler);
}