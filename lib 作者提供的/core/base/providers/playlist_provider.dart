import 'package:spotube/core/base/providers/media_provider.dart';
import 'package:spotube/core/base/interfaces/media/playlist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 播放列表提供者接口
abstract class PlaylistProvider extends MediaProvider<PlaylistInterface> {
  /// 获取播放列表曲目
  Future<List<TrackInterface>> getTracks({int limit = 20, int offset = 0});
  
  /// 添加曲目到播放列表
  Future<bool> addTrack(String trackId);
  
  /// 从播放列表移除曲目
  Future<bool> removeTrack(String trackId);
  
  /// 播放列表曲目
  List<TrackInterface> get tracks;
  
  /// 播放列表曲目是否已加载
  bool get tracksLoaded;
}