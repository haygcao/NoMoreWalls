import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/media/playlist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 播放列表服务接口
abstract class PlaylistService extends BaseService {
  /// 获取播放列表详情
  Future<PlaylistInterface?> getPlaylist(String playlistId);
  
  /// 获取播放列表曲目
  Future<List<TrackInterface>> getPlaylistTracks(String playlistId, {int limit = 20, int offset = 0});
  
  /// 创建播放列表
  Future<PlaylistInterface?> createPlaylist(String name, {String? description});
  
  /// 添加曲目到播放列表
  Future<bool> addTrackToPlaylist(String playlistId, String trackId);
  
  /// 从播放列表移除曲目
  Future<bool> removeTrackFromPlaylist(String playlistId, String trackId);
  
  /// 获取精选播放列表
  Future<List<PlaylistInterface>> getFeaturedPlaylists({int limit = 20, int offset = 0});
  
  /// 获取用户播放列表
  Future<List<PlaylistInterface>> getUserPlaylists({int limit = 20, int offset = 0});
}