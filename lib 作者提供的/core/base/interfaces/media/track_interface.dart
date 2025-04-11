import 'package:spotube/core/base/interfaces/media/media_interface.dart';

/// 音轨接口
abstract class TrackInterface extends MediaInterface {
  /// 艺术家名称
  String? get artistName;
  
  /// 专辑名称
  String? get albumName;
  
  /// 时长（毫秒）
  int? get durationMs;
  
  /// 是否可播放
  bool get isPlayable;
  
  /// 流媒体URL
  Future<String?> getStreamUrl();
}