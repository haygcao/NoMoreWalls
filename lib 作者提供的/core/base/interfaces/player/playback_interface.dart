/// 播放控制接口
abstract class PlaybackInterface {
  /// 设置播放速度
  Future<void> setPlaybackRate(double rate);
  
  /// 设置重复模式
  Future<void> setRepeatMode(RepeatMode mode);
  
  /// 设置随机播放
  Future<void> setShuffle(bool enabled);
  
  /// 跳转到指定位置
  Future<void> seekTo(Duration position);
  
  /// 获取当前播放位置
  Future<Duration> getCurrentPosition();
  
  /// 获取当前曲目总时长
  Future<Duration> getDuration();
  
  /// 当前重复模式
  RepeatMode get repeatMode;
  
  /// 是否随机播放
  bool get shuffleEnabled;
}

/// 重复模式枚举
enum RepeatMode {
  /// 不重复
  off,
  
  /// 重复当前曲目
  track,
  
  /// 重复整个队列
  queue
}