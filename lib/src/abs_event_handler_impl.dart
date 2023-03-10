import 'package:windmill/src/abs_event_handler.dart';
import 'package:windmill/src/action_event_handler.dart';
import 'package:windmill/src/agora_action_event_handler.dart';

class AbsEventHandlerImpl implements AbsEventHandler{
  ActionEventHandler? mHandler;
  AgoraActionEventHandler? mAgoraHandler;
  @override
  void setActionEventHandler(ActionEventHandler handler) {
    mHandler = handler;
  }
  @override
  void setAgoraActionEventHandler(AgoraActionEventHandler handler) {
  mAgoraHandler = handler;
  }
  factory AbsEventHandlerImpl() => _getInstance();
  static AbsEventHandlerImpl get instance => _getInstance();
  static AbsEventHandlerImpl? _instance;
  AbsEventHandlerImpl._() {
    // 初始化
  }

  static AbsEventHandlerImpl _getInstance() {
    _instance ??=  AbsEventHandlerImpl._();
    return _instance!;
  }



}