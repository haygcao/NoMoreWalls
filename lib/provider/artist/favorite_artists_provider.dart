import 'package:hooks_riverpod/hooks_riverpod.dart';
// 为 spotify 包添加前缀
import 'package:spotify/spotify.dart' as spotify;

import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
// 为 artist.dart 添加前缀
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/models/youtube_music/channel.dart';
import 'package:spotube/models/youtube_music/artist.dart';

// 通用的艺术家状态
class FavoriteArtistsState {
  final List<Artist> items;
  final bool hasMore;
  final bool isLoading;

  const FavoriteArtistsState({
    required this.items,
    this.hasMore = false,
    this.isLoading = false,
  });

  FavoriteArtistsState copyWith({
    List<Artist>? items,
    bool? hasMore,
    bool? isLoading,
  }) {
    return FavoriteArtistsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 通用的艺术家提供者
class FavoriteArtistsNotifier extends StateNotifier<AsyncValue<FavoriteArtistsState>> {
  final Ref ref;
  MusicPlatform _currentPlatform = MusicPlatform.spotify;

  FavoriteArtistsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadArtists();
  }

  // 设置当前平台
  void setPlatform(MusicPlatform platform) {
    if (_currentPlatform != platform) {
      _currentPlatform = platform;
      loadArtists();
    }
  }

  // 加载艺术家
  Future<void> loadArtists() async {
    state = const AsyncValue.loading();
    
    try {
      if (_currentPlatform == MusicPlatform.spotify) {
        await _loadSpotifyArtists();
      } else if (_currentPlatform == MusicPlatform.youtubeMusic) {
        await _loadYoutubeMusicArtists();
      } else if (_currentPlatform == MusicPlatform.mixed) {
        await _loadMixedArtists();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 加载更多
  Future<void> fetchMore() async {
    if (state.value == null || state.value!.isLoading || !state.value!.hasMore) return;

    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    
    try {
      if (_currentPlatform == MusicPlatform.spotify) {
        await _loadMoreSpotifyArtists();
      } else if (_currentPlatform == MusicPlatform.youtubeMusic) {
        await _loadMoreYoutubeMusicArtists();
      } else if (_currentPlatform == MusicPlatform.mixed) {
        await _loadMoreMixedArtists();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  // 加载混合模式的艺术家
  Future<void> _loadMixedArtists() async {
    // 加载 Spotify 艺术家
    final spotifyArtistsState = await ref.read(followedArtistsProvider.future);
    final spotifyArtists = spotifyArtistsState.items.map((spotifyArtist) => 
      _convertSpotifyArtist(spotifyArtist)).toList();
    
    // 加载 YouTube Music 艺术家
    List<Artist> youtubeArtists = [];
    try {
      // 使用 youtubeMusicArtistFollowingProvider 获取关注的艺术家
      final followedArtists = await ref.read(youtubeMusicArtistFollowingProvider.future);
      youtubeArtists = followedArtists.map((artist) => _convertYouTubeMusicChannel(artist)).toList();
    } catch (e) {
      // 如果 YouTube Music 加载失败，只使用 Spotify 艺术家
    }
    
    // 合并两个平台的艺术家
    final allArtists = [...spotifyArtists, ...youtubeArtists];
    
    // 按名称排序
    allArtists.sort((a, b) => a.name.compareTo(b.name));
    
    state = AsyncValue.data(FavoriteArtistsState(
      items: allArtists,
      hasMore: spotifyArtistsState.hasMore,
    ));
  }
  // 加载更多混合模式的艺术家
  Future<void> _loadMoreMixedArtists() async {
    final currentArtists = state.value!.items;
    
    // 加载更多 Spotify 艺术家
    final spotifyNotifier = ref.read(followedArtistsProvider.notifier);
    await spotifyNotifier.fetchMore();
    
    final spotifyArtistsState = await ref.read(followedArtistsProvider.future);
    final spotifyArtists = spotifyArtistsState.items.map(_convertSpotifyArtist).toList();
    
    // 找出新加载的 Spotify 艺术家
    final existingIds = currentArtists.map((e) => e.id).toSet();
    final newSpotifyArtists = spotifyArtists.where((artist) => !existingIds.contains(artist.id)).toList();
    
    // 合并并排序
    final allArtists = [...currentArtists, ...newSpotifyArtists];
    allArtists.sort((a, b) => a.name.compareTo(b.name));
    
    state = AsyncValue.data(FavoriteArtistsState(
      items: allArtists,
      hasMore: spotifyArtistsState.hasMore,
      isLoading: false,
    ));
  }
  // Spotify 艺术家加载
  Future<void> _loadSpotifyArtists() async {
    final spotifyArtistsState = await ref.read(followedArtistsProvider.future);
    final artists = spotifyArtistsState.items.map((spotifyArtist) => 
      _convertSpotifyArtist(spotifyArtist)).toList();
    
    state = AsyncValue.data(FavoriteArtistsState(
      items: artists,
      hasMore: spotifyArtistsState.hasMore,
    ));
  }
  // 加载更多 Spotify 艺术家
  Future<void> _loadMoreSpotifyArtists() async {
    final spotifyNotifier = ref.read(followedArtistsProvider.notifier);
    await spotifyNotifier.fetchMore();
    
    final spotifyArtistsState = await ref.read(followedArtistsProvider.future);
    final artists = spotifyArtistsState.items.map((spotifyArtist) => 
      _convertSpotifyArtist(spotifyArtist)).toList();
    
    state = AsyncValue.data(FavoriteArtistsState(
      items: artists,
      hasMore: spotifyArtistsState.hasMore,
    ));
  }
  // YouTube Music 艺术家加载
  Future<void> _loadYoutubeMusicArtists() async {
    // 使用 youtubeMusicArtistFollowingProvider 获取关注的艺术家
    final followedArtists = await ref.read(youtubeMusicArtistFollowingProvider.future);
    final artists = followedArtists.map((artist) => _convertYouTubeMusicChannel(artist)).toList();
    
    state = AsyncValue.data(FavoriteArtistsState(
      items: artists,
      hasMore: false,
    ));
  }
  // 加载更多 YouTube Music 艺术家
  Future<void> _loadMoreYoutubeMusicArtists() async {
    // YouTube Music API 可能不支持分页
    state = AsyncValue.data(state.value!.copyWith(isLoading: false));
  }
  // 转换 Spotify 艺术家到通用 Artist
  Artist _convertSpotifyArtist(spotify.Artist spotifyArtist) {
    return Artist(
      id: spotifyArtist.id!,
      name: spotifyArtist.name!,
      uri: spotifyArtist.uri!,
      imageUrl: spotifyArtist.images?.firstOrNull?.url,
      platformMetadata: {
        'platform': 'spotify',
        'href': spotifyArtist.href,
        'type': spotifyArtist.type,
        'externalUrls': spotifyArtist.externalUrls?.toJson(),
      },
    );
  }
  // 转换 YouTube Music 艺术家到通用 Artist
  Artist _convertYouTubeMusicArtist(YoutubeMusicArtist ytArtist) {
    return Artist(
      id: ytArtist.id,
      name: ytArtist.name,
      uri: 'youtube:artist:${ytArtist.id}',
      imageUrl: ytArtist.thumbnailUrl,
      platformMetadata: {
        'platform': 'youtube_music',
        'browseId': ytArtist.browseId,
      },
    );
  }
  // 转换 YouTube Music Channel 到通用 Artist
  Artist _convertYouTubeMusicChannel(YoutubeMusicChannel channel) {
    return Artist(
      id: channel.id,
      name: channel.name,
      uri: 'youtube:artist:${channel.id}',
      imageUrl: channel.thumbnailUrl,
      platformMetadata: {
        'platform': 'youtube_music',
        'browseId': channel.id,
      },
    );
  }
}

// 通用艺术家提供者
final unifiedFavoriteArtistsProvider = StateNotifierProvider<FavoriteArtistsNotifier, AsyncValue<FavoriteArtistsState>>((ref) {
  return FavoriteArtistsNotifier(ref);
});



