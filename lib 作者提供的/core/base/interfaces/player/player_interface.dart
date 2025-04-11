import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 播放器接口
abstract class PlayerInterface {
  /// 播放指定曲目
  Future<void> play(TrackInterface track);
  
  /// 暂停播放
  Future<void> pause();
  
  /// 恢复播放
  Future<void> resume();
  
  /// 停止播放
  Future<void> stop();
  
  /// 跳到下一曲
  Future<void> next();
  
  /// 跳到上一曲
  Future<void> previous();
  
  /// 设置音量
  Future<void> setVolume(double volume);
  
  /// 获取当前播放状态
  Future<Map<String, dynamic>> getPlaybackState();
  
  /// 当前是否正在播放
  bool get isPlaying;
  
  /// 当前播放的曲目
  TrackInterface? get currentTrack;
}