import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/base/playlist.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/models/spotify/adapters.dart';
import 'package:spotube/models/spotify/sourceable_track_adapter.dart';


// 播放列表服务接口
abstract class PlaylistService {
  Future<List<Playlist>> getUserPlaylists();
  Future<void> addTracksToPlaylist(String playlistId, List<String> trackIds);
  Future<void> removeTracksFromPlaylist(String playlistId, List<String> trackIds);
  Future<String?> createPlaylist(String name, {String? description, bool isPublic = true, bool? collaborative, String? base64Image});
  Future<void> modifyPlaylist(String playlistId, String name, {String? description, bool? isPublic, bool? collaborative, String? base64Image});
  Future<List<SourceableTrack>> getPlaylistTracks(String playlistId);
}

// Spotify 播放列表服务实现
class SpotifyPlaylistService implements PlaylistService {
  final Ref _ref;
  
  SpotifyPlaylistService(this._ref);
  
  @override
  Future<List<Playlist>> getUserPlaylists() async {
    final playlistsData = await _ref.read(favoritePlaylistsProvider.notifier).fetchAll();
    // 修复 items 访问
    return playlistsData.map((spotifyPlaylist) {
      final adapter = SpotifyPlaylistAdapter(spotifyPlaylist);
      return Playlist(
        id: adapter.id,
        name: adapter.name,
        uri: spotifyPlaylist.uri ?? '',
        description: adapter.description,
        imageUrl: adapter.imageUrl,
        owner: adapter.owner,
        isPublic: adapter.isPublic,
        collaborative: adapter.collaborative,
        totalTracks: adapter.totalTracks,
        platformMetadata: {'platform': 'spotify'},
      );
    }).toList();
  }
  
  @override
  Future<String?> createPlaylist(String name, {String? description, bool isPublic = true, bool? collaborative, String? base64Image}) async {
    final spotify = _ref.read(spotifyProvider);
    // 使用 spotify API 直接创建播放列表
    final playlist = await spotify.playlists.createPlaylist(
      _ref.read(meProvider).value!.id!,
      name,
      description: description,
      public: isPublic,
      collaborative: collaborative,
    );
    
    // 如果提供了图片，上传图片
    if (base64Image != null && playlist.id != null) {
      await spotify.playlists.updatePlaylistImage(playlist.id!, base64Image);
    }
    
    return playlist.id;
  }
  
  @override
  Future<void> modifyPlaylist(String playlistId, String name, {String? description, bool? isPublic, bool? collaborative, String? base64Image}) async {
    final spotify = _ref.read(spotifyProvider);
    // 修改播放列表信息
    await spotify.playlists.updatePlaylist(
      playlistId,
      name,
      description: description,
      public: isPublic,
      collaborative: collaborative,
    );
    
    // 如果提供了图片，上传图片
    if (base64Image != null) {
      await spotify.playlists.updatePlaylistImage(playlistId, base64Image);
    }
  }
  
  @override
  Future<void> addTracksToPlaylist(String playlistId, List<String> trackIds) async {
    final spotify = _ref.read(spotifyProvider);
    // 使用 Spotify API 添加曲目到播放列表
    await spotify.playlists.addTracks(
      trackIds.map((id) => 'spotify:track:$id').toList(),
      playlistId,
    );
  }
  
  @override
  Future<void> removeTracksFromPlaylist(String playlistId, List<String> trackIds) async {
    final spotify = _ref.read(spotifyProvider);
    // 使用 Spotify API 从播放列表移除曲目
    await spotify.playlists.removeTracks(
      trackIds.map((id) => 'spotify:track:$id').toList(),
      playlistId,
    );
  }

  // 在 SpotifyPlaylistService 类中
  @override
  Future<List<SourceableTrack>> getPlaylistTracks(String playlistId) async {
    final playlistTracks = await _ref.read(playlistTracksProvider(playlistId).future);
    // 使用新的适配器类
    return playlistTracks.items
        .map((track) => SpotifySourceableTrackAdapter(track))
        .toList();
  }

}
// YouTube Music 播放列表服务实现
class YouTubeMusicPlaylistService implements PlaylistService {
  final Ref _ref;
  
  YouTubeMusicPlaylistService(this._ref);
  
  @override
  Future<List<Playlist>> getUserPlaylists() async {
    final service = _ref.read(youtubeMusicProvider);
    final playlistsData = await service.getUserPlaylists();
    // 将 YouTube Music 播放列表转换为通用 Playlist 模型
    return playlistsData.map((ytPlaylist) => Playlist(
      id: ytPlaylist.id,
      name: ytPlaylist.title,
      uri: 'https://music.youtube.com/playlist?list=${ytPlaylist.id}',
      description: ytPlaylist.description,
      imageUrl: ytPlaylist.thumbnailUrl,
      owner: ytPlaylist.authorName, // Changed from owner to authorName
      isPublic: true, // YouTube Music 默认为公开
      collaborative: false, // YouTube Music 不支持协作
      totalTracks: ytPlaylist.trackCount,
      platformMetadata: {'platform': 'youtube_music'},
    )).toList();
  }
  
  @override
  Future<void> addTracksToPlaylist(String playlistId, List<String> trackIds) async {
    final playlistActions = _ref.read(youtubeMusicPlaylistActionsProvider);
    for (final trackId in trackIds) {
      await playlistActions.addTrackToPlaylist(playlistId, trackId);
    }
  }
  
  @override
  Future<void> removeTracksFromPlaylist(String playlistId, List<String> trackIds) async {
    final playlistActions = _ref.read(youtubeMusicPlaylistActionsProvider);
    for (final trackId in trackIds) {
      await playlistActions.removeTrackFromPlaylist(playlistId, trackId);
    }
  }
  
  @override
  Future<String?> createPlaylist(String name, {String? description, bool isPublic = true, bool? collaborative, String? base64Image}) async {
    // YouTube Music 不支持协作播放列表和图片上传，忽略这些参数
    final playlist = await _ref.read(youtubeMusicPlaylistActionsProvider).createPlaylist(name, description: description);
    return playlist.id;
  }
  
  @override
  Future<void> modifyPlaylist(String playlistId, String name, {String? description, bool? isPublic, bool? collaborative, String? base64Image}) async {
    // YouTube Music 不支持协作播放列表和图片上传，忽略这些参数
    final service = _ref.read(youtubeMusicProvider);
    await service.modifyPlaylist(playlistId, name, description: description);
  }
  
  @override
  Future<List<SourceableTrack>> getPlaylistTracks(String playlistId) async {
    final tracks = await _ref.read(youtubeMusicPlaylistTracksProvider(playlistId).future);
    // 确保返回的是 SourceableTrack 类型
    return tracks.map<SourceableTrack>((track) => track as SourceableTrack).toList();
  }
  

}

class UnifiedPlaylistProvider extends StateNotifier<Map<MusicPlatform, AsyncValue<List<Playlist>>>> {
  final Map<MusicPlatform, PlaylistService> _services;
  final Ref ref;

  UnifiedPlaylistProvider(this.ref, this._services) : super({
    for (final platform in MusicPlatform.values)
      platform: const AsyncValue.data([])
  });

  Future<void> fetchPlaylists(MusicPlatform platform) async {
    try {
      state = {
        ...state,
        platform: const AsyncValue.loading(),
      };

      final playlists = await _services[platform]?.getUserPlaylists() ?? [];
      
      state = {
        ...state,
        platform: AsyncValue.data(playlists),
      };
    } catch (e, stack) {
      state = {
        ...state,
        platform: AsyncValue.error(e, stack),
      };
    }
  }

  Future<void> addTracks(MusicPlatform platform, String playlistId, List<String> trackIds) async {
    await _services[platform]?.addTracksToPlaylist(playlistId, trackIds);
    // 刷新播放列表
    await fetchPlaylists(platform);
  }

  Future<void> removeTracks(MusicPlatform platform, String playlistId, List<String> trackIds) async {
    await _services[platform]?.removeTracksFromPlaylist(playlistId, trackIds);
    // 刷新播放列表
    await fetchPlaylists(platform);
  }

  Future<String?> createPlaylist(
    MusicPlatform platform, 
    String name, 
    {String? description, bool isPublic = true, bool? collaborative, String? base64Image}
  ) async {
    return await _services[platform]?.createPlaylist(
      name, 
      description: description, 
      isPublic: isPublic,
      collaborative: collaborative,
      base64Image: base64Image,
    );
  }
  
  Future<void> modifyPlaylist(
    MusicPlatform platform, 
    String playlistId, 
    String name, 
    {String? description, bool? isPublic, bool? collaborative, String? base64Image}
  ) async {
    await _services[platform]?.modifyPlaylist(
      playlistId, 
      name, 
      description: description, 
      isPublic: isPublic,
      collaborative: collaborative,
      base64Image: base64Image,
    );
    // 刷新播放列表
    await fetchPlaylists(platform);
  }

  Future<List<SourceableTrack>> getPlaylistTracks(MusicPlatform platform, String playlistId) async {
    return await _services[platform]?.getPlaylistTracks(playlistId) ?? [];
  }
}

final unifiedPlaylistProvider = StateNotifierProvider<UnifiedPlaylistProvider, Map<MusicPlatform, AsyncValue<List<Playlist>>>>((ref) {
  return UnifiedPlaylistProvider(
    ref,
    {
      MusicPlatform.spotify: SpotifyPlaylistService(ref),
      MusicPlatform.youtubeMusic: YouTubeMusicPlaylistService(ref),
    },
  );
});

// 便捷访问当前平台的播放列表
final currentPlatformPlaylistsProvider = Provider<AsyncValue<List<Playlist>>>((ref) {
  final currentPlatform = ref.watch(currentMusicPlatformProvider);
  final playlists = ref.watch(unifiedPlaylistProvider);
  return playlists[currentPlatform] ?? const AsyncValue.data([]);
});

