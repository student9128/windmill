class ActionEventHandler {
  /// 返回点击
  Function? onBackClick;

  /// 横竖屏切换点击
  Function(bool landscape)? onRotateScreenClick;

  /// 视频进度回调
  Function(String time)? onVideoProgress;

  ///播放/暂停按钮点击
  ///
  ///isPlaying 点击的时候是否播放
  Function(bool isPlaying)? onPlayClick;

  ///后台播放开关是否打开点击
  Function(bool allowBackgroundPlay)? onBackgroundPlayClick;

  /// 收藏点击
  Function? onCollectClick;

  /// 分享点击
  Function? onShareClick;

  /// 画中画点击
  Function? onPipClick;

  ///设置点击
  Function? onSettingClick;

  ///直播刷新点击
  Function? onRefreshClick;

  Function? onResumed;
  Function? onPaused;
  Function? onInactive;
  Function? onDetached;

  Function(int videoStreamType)? onVideoStreamTypeClick;



  ActionEventHandler(
      {this.onBackClick,
      this.onRotateScreenClick,
      this.onVideoProgress,
      this.onPlayClick,
      this.onBackgroundPlayClick,
      this.onCollectClick,
      this.onShareClick,
      this.onPipClick,
      this.onSettingClick,
      this.onRefreshClick,
      this.onVideoStreamTypeClick,
      this.onResumed,
      this.onPaused,
      this.onInactive,
      this.onDetached});
}
