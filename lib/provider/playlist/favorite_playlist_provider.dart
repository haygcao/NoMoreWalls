import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart' hide Playlist, Track;
import 'package:spotube/models/spotify/track_adapter.dart';
import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/services/base/playlist.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:collection/collection.dart';

class FavoritePlaylistsState {
  final List<Playlist> items;
  final bool hasMore;
  final bool isLoading;

  const FavoritePlaylistsState({
    required this.items,
    this.hasMore = false,
    this.isLoading = false,
  });

  FavoritePlaylistsState copyWith({
    List<Playlist>? items,
    bool? hasMore,
    bool? isLoading,
  }) {
    return FavoritePlaylistsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavoritePlaylistsNotifier extends StateNotifier<AsyncValue<FavoritePlaylistsState>> {
  final Ref ref;
  MusicPlatform _currentPlatform = MusicPlatform.spotify;

  FavoritePlaylistsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadPlaylists();
  }

  void setPlatform(MusicPlatform platform) {
    if (_currentPlatform != platform) {
      _currentPlatform = platform;
      loadPlaylists();
    }
  }

  Future<void> loadPlaylists() async {
    state = const AsyncValue.loading();
    
    try {
      if (_currentPlatform == MusicPlatform.spotify) {
        await _loadSpotifyPlaylists();
      } else if (_currentPlatform == MusicPlatform.youtubeMusic) {
        await _loadYoutubeMusicPlaylists();
      } else if (_currentPlatform == MusicPlatform.mixed) {
        await _loadMixedPlaylists();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchMore() async {
    if (state.value == null || state.value!.isLoading || !state.value!.hasMore) return;

    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    
    try {
      if (_currentPlatform == MusicPlatform.spotify) {
        await _loadMoreSpotifyPlaylists();
      } else if (_currentPlatform == MusicPlatform.youtubeMusic) {
        await _loadMoreYoutubeMusicPlaylists();
      } else if (_currentPlatform == MusicPlatform.mixed) {
        await _loadMoreMixedPlaylists();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _loadSpotifyPlaylists() async {
    final spotifyPlaylistsState = await ref.read(favoritePlaylistsProvider.future);
    final playlists = spotifyPlaylistsState.items.map(_convertSpotifyPlaylist).toList();
    
    state = AsyncValue.data(FavoritePlaylistsState(
      items: playlists,
      hasMore: spotifyPlaylistsState.hasMore,
    ));
  }

  Future<void> _loadMoreSpotifyPlaylists() async {
    final spotifyNotifier = ref.read(favoritePlaylistsProvider.notifier);
    await spotifyNotifier.fetchMore();
    
    final spotifyPlaylistsState = await ref.read(favoritePlaylistsProvider.future);
    final playlists = spotifyPlaylistsState.items.map(_convertSpotifyPlaylist).toList();
    
    state = AsyncValue.data(FavoritePlaylistsState(
      items: playlists,
      hasMore: spotifyPlaylistsState.hasMore,
      isLoading: false,
    ));
  }

  Future<void> _loadYoutubeMusicPlaylists() async {
    final youtubeMusicPlaylists = await ref.read(youtubeMusicUserPlaylistsProvider.future);
    final playlists = youtubeMusicPlaylists.map(_convertYouTubeMusicPlaylist).toList();
    
    state = AsyncValue.data(FavoritePlaylistsState(
      items: playlists,
      hasMore: false,
    ));
  }

  Future<void> _loadMoreYoutubeMusicPlaylists() async {
    // YouTube Music 可能不支持分页加载
    state = AsyncValue.data(state.value!.copyWith(isLoading: false));
  }

  Future<void> _loadMixedPlaylists() async {
    // 加载 Spotify 播放列表
    final spotifyPlaylistsState = await ref.read(favoritePlaylistsProvider.future);
    final spotifyPlaylists = spotifyPlaylistsState.items.map(_convertSpotifyPlaylist).toList();
    
    // 加载 YouTube Music 播放列表
    List<Playlist> youtubePlaylists = [];
    try {
      final youtubeMusicPlaylists = await ref.read(youtubeMusicUserPlaylistsProvider.future);
      youtubePlaylists = youtubeMusicPlaylists.map(_convertYouTubeMusicPlaylist).toList();
    } catch (e) {
      // 如果 YouTube Music 加载失败，只使用 Spotify 播放列表
    }
    
    // 合并并排序
    final allPlaylists = [...spotifyPlaylists, ...youtubePlaylists];
    allPlaylists.sort((a, b) => a.name.compareTo(b.name));
    
    state = AsyncValue.data(FavoritePlaylistsState(
      items: allPlaylists,
      hasMore: spotifyPlaylistsState.hasMore,
    ));
  }

  Future<void> _loadMoreMixedPlaylists() async {
    final currentPlaylists = state.value!.items;
    
    // 加载更多 Spotify 播放列表
    final spotifyNotifier = ref.read(favoritePlaylistsProvider.notifier);
    await spotifyNotifier.fetchMore();
    
    final spotifyPlaylistsState = await ref.read(favoritePlaylistsProvider.future);
    final spotifyPlaylists = spotifyPlaylistsState.items.map(_convertSpotifyPlaylist).toList();
    
    // 找出新加载的播放列表
    final existingIds = currentPlaylists.map((e) => e.id).toSet();
    final newSpotifyPlaylists = spotifyPlaylists.where((playlist) => !existingIds.contains(playlist.id)).toList();
    
    // 合并并排序
    final allPlaylists = [...currentPlaylists, ...newSpotifyPlaylists];
    allPlaylists.sort((a, b) => a.name.compareTo(b.name));
    
    state = AsyncValue.data(FavoritePlaylistsState(
      items: allPlaylists,
      hasMore: spotifyPlaylistsState.hasMore,
      isLoading: false,
    ));
  }

  // 转换 Spotify 播放列表到通用 Playlist
  Playlist _convertSpotifyPlaylist(PlaylistSimple spotifyPlaylist) {
    return Playlist(
      id: spotifyPlaylist.id!,
      name: spotifyPlaylist.name!,
      description: spotifyPlaylist.description,
      imageUrl: spotifyPlaylist.images?.firstOrNull?.url,
      uri: spotifyPlaylist.uri!,
      isPublic: spotifyPlaylist.public ?? false,
      collaborative: spotifyPlaylist.collaborative ?? false,
      owner: spotifyPlaylist.owner?.displayName,
      totalTracks: 0, // PlaylistSimple 可能没有 tracks 信息
      platformMetadata: {
        'platform': 'spotify',
        'href': spotifyPlaylist.href,
        'type': spotifyPlaylist.type,
        'externalUrls': spotifyPlaylist.externalUrls?.toJson(),
      },
    );
  }

  // 转换 YouTube Music 播放列表到通用 Playlist
  Playlist _convertYouTubeMusicPlaylist(YoutubeMusicPlaylist ytPlaylist) {
    return Playlist(
      id: ytPlaylist.id,
      name: ytPlaylist.title,
      description: ytPlaylist.description,
      imageUrl: ytPlaylist.thumbnailUrl,
      uri: 'youtube:playlist:${ytPlaylist.id}',
      isPublic: true, // YouTube Music 默认为公开
      collaborative: false, // YouTube Music 不支持协作播放列表
      owner: ytPlaylist.authorName,
      totalTracks: ytPlaylist.trackCount,
      platformMetadata: {
        'platform': 'youtube_music',
        'authorId': ytPlaylist.authorId,
      },
    );
  }
}

// 统一的播放列表提供者
final unifiedFavoritePlaylistsProvider = StateNotifierProvider<FavoritePlaylistsNotifier, AsyncValue<FavoritePlaylistsState>>((ref) {
  return FavoritePlaylistsNotifier(ref);
});