import 'package:spotube/core/base/providers/base_provider.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/interfaces/player/playback_interface.dart';

/// 播放器提供者接口
abstract class PlayerProvider extends BaseProvider<Map<String, dynamic>> {
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
  
  /// 设置播放速度
  Future<void> setPlaybackRate(double rate);
  
  /// 设置重复模式
  Future<void> setRepeatMode(RepeatMode mode);
  
  /// 设置随机播放
  Future<void> setShuffle(bool enabled);
  
  /// 跳转到指定位置
  Future<void> seekTo(Duration position);
  
  /// 当前是否正在播放
  bool get isPlaying;
  
  /// 当前播放的曲目
  TrackInterface? get currentTrack;
  
  /// 当前重复模式
  RepeatMode get repeatMode;
  
  /// 是否随机播放
  bool get shuffleEnabled;
  
  /// 当前播放位置
  Duration get position;
  
  /// 当前曲目总时长
  Duration get duration;
  
  /// 当前音量
  double get volume;
}