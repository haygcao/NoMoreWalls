import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotify/spotify.dart' show FollowingType, Track; // 添加 Track 导入
import 'package:spotube/models/spotify/adapters.dart';
import 'package:spotube/models/youtube_music/album_adapter.dart';

import 'package:spotube/models/youtube_music/channel.dart';

import 'package:spotube/models/spotify/sourceable_track_adapter.dart'; // 导入 SpotifySourceableTrackAdapter
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/sourceable_track.dart';


// 统一的艺术家提供者
final unifiedArtistProvider = FutureProvider.autoDispose.family<Artist, String>(
  (ref, artistId) async {
    // 获取当前平台
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      // 使用 YouTube Music 服务获取艺术家
      final ytArtist =
          await ref.watch(youtubeMusicArtistProvider(artistId).future);
      return _convertYouTubeMusicChannel(ytArtist);
    } else {
      // 默认使用 Spotify 服务获取艺术家
      final spotifyArtist = await ref.watch(artistProvider(artistId).future);
      return _convertSpotifyArtist(spotifyArtist);
    }
  },
);

// 检查艺术家是否被关注的提供者
final isArtistFollowedProvider =
    FutureProvider.autoDispose.family<bool, String>(
  (ref, artistId) async {
    // 使用 currentMusicPlatformProvider
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      // 使用 YouTube Music 服务检查艺术家是否被关注
      return ref.watch(youtubeMusicArtistIsFollowingProvider(artistId).future);
    } else {
      // 默认使用 Spotify 服务检查艺术家是否被关注
      return ref.watch(artistIsFollowingProvider(artistId).future);
    }
  },
);

// 关注艺术家的提供者
final followedArtistsNotifierProvider =
    StateNotifierProvider<FollowedArtistsNotifier, AsyncValue<void>>(
  (ref) => FollowedArtistsNotifier(ref),
);

// 关注艺术家的 Notifier
class FollowedArtistsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  FollowedArtistsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> followArtist(String artistId) async {
    state = const AsyncValue.loading();
    try {
      // 使用 currentMusicPlatformProvider
      final platform = ref.read(currentMusicPlatformProvider);

      if (platform == MusicPlatform.youtubeMusic) {
        // 使用 YouTube Music 服务关注艺术家
        final youtubeMusic = ref.read(youtubeMusicProvider);
        await youtubeMusic.subscribeToChannel(artistId);
      } else {
        // 默认使用 Spotify 服务关注艺术家
        final spotify = ref.read(spotifyProvider);
        // 直接使用 FollowingType 而不是 spotify.FollowingType
        await spotify.me.follow(FollowingType.artist, [artistId]);
      }

      state = const AsyncValue.data(null);
      // 刷新关注的艺术家列表
      ref.invalidate(unifiedFavoriteArtistsProvider);
      ref.invalidate(isArtistFollowedProvider(artistId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unfollowArtist(String artistId) async {
    state = const AsyncValue.loading();
    try {
      // 使用 currentMusicPlatformProvider
      final platform = ref.read(currentMusicPlatformProvider);

      if (platform == MusicPlatform.youtubeMusic) {
        // 使用 YouTube Music 服务取消关注艺术家
        final youtubeMusic = ref.read(youtubeMusicProvider);
        await youtubeMusic.unsubscribeFromChannel(artistId);
      } else {
        // 默认使用 Spotify 服务取消关注艺术家
        final spotify = ref.read(spotifyProvider);
        // 直接使用 FollowingType 而不是 spotify.FollowingType
        await spotify.me.unfollow(FollowingType.artist, [artistId]);
      }

      state = const AsyncValue.data(null);
      // 刷新关注的艺术家列表
      ref.invalidate(unifiedFavoriteArtistsProvider);
      ref.invalidate(isArtistFollowedProvider(artistId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

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
class FavoriteArtistsNotifier
    extends StateNotifier<AsyncValue<FavoriteArtistsState>> {
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
    if (state.value == null ||
        state.value!.isLoading ||
        !state.value!.hasMore) {
      return;
    }

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
    final spotifyArtists = await _getSpotifyArtists();

    // 加载 YouTube Music 艺术家
    List<Artist> youtubeArtists = [];
    try {
      // 使用 youtubeMusicArtistFollowingProvider 获取关注的艺术家
      final followedArtists =
          await ref.read(youtubeMusicArtistFollowingProvider.future);
      youtubeArtists = followedArtists
          .map((artist) => _convertYouTubeMusicChannel(artist))
          .toList();
    } catch (e) {
      // 如果 YouTube Music 加载失败，只使用 Spotify 艺术家
    }

    // 合并两个平台的艺术家
    final allArtists = [...spotifyArtists, ...youtubeArtists];

    // 按名称排序
    allArtists.sort((a, b) => a.name.compareTo(b.name));

    state = AsyncValue.data(FavoriteArtistsState(
      items: allArtists,
      hasMore: false,
    ));
  }

  // 加载更多混合模式的艺术家
  Future<void> _loadMoreMixedArtists() async {
    final currentArtists = state.value!.items;

    // 加载更多 Spotify 艺术家
    final spotifyArtists = await _getMoreSpotifyArtists();

    // 找出新加载的 Spotify 艺术家
    final existingIds = currentArtists.map((e) => e.id).toSet();
    final newSpotifyArtists = spotifyArtists
        .where((artist) => !existingIds.contains(artist.id))
        .toList();

    // 合并并排序
    final allArtists = [...currentArtists, ...newSpotifyArtists];
    allArtists.sort((a, b) => a.name.compareTo(b.name));

    state = AsyncValue.data(FavoriteArtistsState(
      items: allArtists,
      hasMore: false,
      isLoading: false,
    ));
  }

  // 获取 Spotify 艺术家
  Future<List<Artist>> _getSpotifyArtists() async {
    final spotify = ref.read(spotifyProvider);
    // 直接使用 FollowingType 而不是 spotify.FollowingType
    final artists = await spotify.me.following(FollowingType.artist).all();
    return artists.map((artist) => _convertSpotifyArtist(artist)).toList();
  }

  // 获取更多 Spotify 艺术家
  Future<List<Artist>> _getMoreSpotifyArtists() async {
    // 这里应该实现分页加载，但简化处理
    return [];
  }

  // Spotify 艺术家加载
  Future<void> _loadSpotifyArtists() async {
    final artists = await _getSpotifyArtists();

    state = AsyncValue.data(FavoriteArtistsState(
      items: artists,
      hasMore: false,
    ));
  }

  // 加载更多 Spotify 艺术家
  Future<void> _loadMoreSpotifyArtists() async {
    final moreArtists = await _getMoreSpotifyArtists();

    if (moreArtists.isEmpty) {
      state = AsyncValue.data(state.value!.copyWith(
        hasMore: false,
        isLoading: false,
      ));
      return;
    }

    final currentArtists = state.value!.items;
    final allArtists = [...currentArtists, ...moreArtists];

    state = AsyncValue.data(FavoriteArtistsState(
      items: allArtists,
      hasMore: true,
      isLoading: false,
    ));
  }

  // YouTube Music 艺术家加载
  Future<void> _loadYoutubeMusicArtists() async {
    // 使用 youtubeMusicArtistFollowingProvider 获取关注的艺术家
    final followedArtists =
        await ref.read(youtubeMusicArtistFollowingProvider.future);
    final artists = followedArtists
        .map((artist) => _convertYouTubeMusicChannel(artist))
        .toList();

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
}

// 通用艺术家提供者
final unifiedFavoriteArtistsProvider = StateNotifierProvider<
    FavoriteArtistsNotifier, AsyncValue<FavoriteArtistsState>>((ref) {
  return FavoriteArtistsNotifier(ref);
});

// 转换 Spotify 艺术家到通用 Artist
Artist _convertSpotifyArtist(spotify.Artist spotifyArtist) {
  return Artist(
    id: spotifyArtist.id!,
    name: spotifyArtist.name!,
    uri: spotifyArtist.uri!,
    imageUrl: spotifyArtist.images?.isNotEmpty == true
        ? spotifyArtist.images!.first.url
        : null,
    description: null,
    platformMetadata: {
      'platform': 'spotify',
      'type': spotifyArtist.type,
      'href': spotifyArtist.href,
      'followers': spotifyArtist.followers?.total?.toDouble() ?? 0,
      'externalUrls': spotifyArtist.externalUrls?.toJson(),
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
    description: channel.description,
    platformMetadata: {
      'platform': 'youtube_music',
      'browseId': channel.id,
      'followers': channel.subscriberCount.toDouble(),
      'externalUrls': {
        'youtube': "https://music.youtube.com/channel/${channel.id}"
      }
    },
  );
}

// 统一的相关艺术家提供者
final unifiedRelatedArtistsProvider =
    FutureProvider.autoDispose.family<List<Artist>, String>(
  (ref, artistId) async {
    // 获取当前平台
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      // 使用 YouTube Music 服务获取相关艺术家
      try {
        final youtubeMusic = ref.read(youtubeMusicProvider);
        // 直接使用新添加的 getRelatedArtists 方法
        final relatedChannels = await youtubeMusic.getRelatedArtists(artistId);
        return relatedChannels
            .map((channel) => _convertYouTubeMusicChannel(channel))
            .toList();
      } catch (e) {
        // 如果 YouTube Music 获取失败，尝试使用 Spotify
        final spotifyArtists =
            await ref.read(relatedArtistsProvider(artistId).future);
        return spotifyArtists
            .map((artist) => _convertSpotifyArtist(artist))
            .toList();
      }
    } else {
      // 默认使用 Spotify 服务获取相关艺术家
      final spotifyArtists =
          await ref.read(relatedArtistsProvider(artistId).future);
      return spotifyArtists
          .map((artist) => _convertSpotifyArtist(artist))
          .toList();
    }
  },
);

// 统一的艺术家顶部曲目提供者
final unifiedArtistTopTracksProvider = FutureProvider.autoDispose.family<List<SourceableTrack>, String>(
  (ref, artistId) async {
    // 获取当前平台
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      // 使用 YouTube Music 服务获取艺术家顶部曲目
      try {
        final youtubeMusic = ref.read(youtubeMusicProvider);
        final topTracks = await youtubeMusic.getArtistTopTracks(artistId);
        
        // YoutubeMusicTrack 已经实现了 SourceableTrack 接口，可以直接返回
        return topTracks;
      } catch (e) {
        // 如果 YouTube Music 获取失败，尝试使用 Spotify
        final spotifyTracks = await ref.read(artistTopTracksProvider(artistId).future);
        // 将 Spotify Track 转换为 SpotifySourceableTrackAdapter
        return spotifyTracks.map((track) => SpotifySourceableTrackAdapter(track)).toList();
      }
    } else {
      // 默认使用 Spotify 服务获取艺术家顶部曲目
      final spotifyTracks = await ref.read(artistTopTracksProvider(artistId).future);
      
      // 将 Spotify Track 转换为 SpotifySourceableTrackAdapter
      return spotifyTracks.map((track) => SpotifySourceableTrackAdapter(track)).toList();
    }
  },
);

// 统一的艺术家专辑提供者
final unifiedArtistAlbumsProvider = FutureProvider.autoDispose.family<List<AlbumBase>, String>(
  (ref, artistId) async {
    // 获取当前平台
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      // 使用 YouTube Music 服务获取艺术家专辑
      try {
        final youtubeMusic = ref.read(youtubeMusicProvider);
        final albums = await youtubeMusic.getArtistAlbums(artistId);
        // 需要将 YoutubeMusicAlbum 转换为 AlbumBase
        return albums.map((album) => YoutubeMusicAlbumAdapter(album)).toList();
      } catch (e) {
        // 如果 YouTube Music 获取失败，尝试使用 Spotify
        final albumsState = await ref.read(artistAlbumsProvider(artistId).future);
        return albumsState.items.map((album) => SpotifyAlbumAdapter(album)).toList();
      }
    } else {
      // 默认使用 Spotify 服务获取艺术家专辑
      final albumsState = await ref.read(artistAlbumsProvider(artistId).future);
      return albumsState.items.map((album) => SpotifyAlbumAdapter(album)).toList();
    }
  },
);

// 删除 _convertSpotifyAlbum 函数，因为现在使用 SpotifyAlbumAdapter 替代
