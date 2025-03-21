part of '../youtube_music.dart';

// 播放列表详情
final youtubeMusicPlaylistProvider = FutureProvider.family<YoutubeMusicPlaylist, String>((ref, playlistId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getPlaylist(playlistId);
});

// 播放列表歌曲
final youtubeMusicPlaylistTracksProvider = FutureProvider.family<List<YoutubeMusicTrack>, String>((ref, playlistId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getPlaylistTracks(playlistId);
});

// 用户播放列表
final youtubeMusicUserPlaylistsProvider = FutureProvider<List<YoutubeMusicPlaylist>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getUserPlaylists();
});

// 播放列表操作提供者
final youtubeMusicPlaylistActionsProvider = Provider<YoutubeMusicPlaylistActions>((ref) {
  final service = ref.watch(youtubeMusicProvider);
  return YoutubeMusicPlaylistActions(service);
});

// 播放列表操作类
class YoutubeMusicPlaylistActions {
  final YoutubeMusicService _service;

  YoutubeMusicPlaylistActions(this._service);

  // 添加音轨到播放列表
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    await _service.addTrackToPlaylist(playlistId, trackId);
  }

  // 从播放列表移除音轨
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    await _service.removeTrackFromPlaylist(playlistId, trackId);
  }

  // 创建播放列表
  Future<YoutubeMusicPlaylist> createPlaylist(String name, {String? description}) async {
    return await _service.createPlaylist(name, description: description);
  }

  // 修改播放列表
  Future<void> modifyPlaylist(String playlistId, String name, {String? description}) async {
    await _service.modifyPlaylist(playlistId, name, description: description);
  }

  // 删除播放列表
  Future<void> deletePlaylist(String playlistId) async {
    await _service.deletePlaylist(playlistId);
  }
}

// 移除重复定义的 youtubeMusicLikedTracksProvider
// 或者将其重命名为 youtubeMusicLikedTracksDataProvider
final youtubeMusicLikedTracksDataProvider = FutureProvider<List<YoutubeMusicTrack>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getLikedTracks();
});