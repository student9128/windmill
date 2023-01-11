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

  /// 收藏点击
  Function? onCollectClick;

  /// 分享点击
  Function? onShareClick;

  /// 画中画点击
  Function? onPipClick;

  ///设置点击
  Function? onSettingClick;

  ActionEventHandler(
      {this.onBackClick,
      this.onRotateScreenClick,
      this.onVideoProgress,
      this.onPlayClick,
      this.onCollectClick,
      this.onShareClick,
      this.onPipClick,
      this.onSettingClick});
}
