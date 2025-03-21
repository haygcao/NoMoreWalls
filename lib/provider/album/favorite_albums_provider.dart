import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart' hide Album;
import 'package:spotube/models/youtube_music/album.dart';

import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/base/album.dart';

// 通用的专辑状态
class FavoriteAlbumsState {
  final List<Album> items;
  final bool hasMore;
  final bool isLoading;

  const FavoriteAlbumsState({
    required this.items,
    this.hasMore = false,
    this.isLoading = false,
  });

  FavoriteAlbumsState copyWith({
    List<Album>? items,
    bool? hasMore,
    bool? isLoading,
  }) {
    return FavoriteAlbumsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 通用的专辑提供者
class FavoriteAlbumsNotifier extends StateNotifier<AsyncValue<FavoriteAlbumsState>> {
  final Ref ref;
  MusicPlatform _currentPlatform = MusicPlatform.spotify;

  FavoriteAlbumsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadAlbums();
  }

  // 设置当前平台
  void setPlatform(MusicPlatform platform) {
    if (_currentPlatform != platform) {
      _currentPlatform = platform;
      loadAlbums();
    }
  }
  // 加载专辑
  Future<void> loadAlbums() async {
    state = const AsyncValue.loading();
    
    try {
      if (_currentPlatform == MusicPlatform.spotify) {
        await _loadSpotifyAlbums();
      } else if (_currentPlatform == MusicPlatform.youtubeMusic) {
        await _loadYoutubeMusicAlbums();
      } else if (_currentPlatform == MusicPlatform.mixed) {
        // 混合模式：加载两个平台的专辑
        await _loadMixedAlbums();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  // 加载混合模式的专辑
  Future<void> _loadMixedAlbums() async {
    // 加载 Spotify 专辑
    final spotifyAlbumsState = await ref.read(favoriteAlbumsProvider.future);
    final spotifyAlbums = spotifyAlbumsState.items.map(_convertSpotifyAlbum).toList();
    
    // 加载 YouTube Music 专辑
    List<Album> youtubeAlbums = [];
    try {
      final library = await ref.read(youtubeMusicUserLibraryProvider.future);
      youtubeAlbums = library.albums.map(_convertYouTubeMusicAlbum).toList();
    } catch (e) {
      // 如果 YouTube Music 加载失败，只使用 Spotify 专辑
    }
    
    // 合并两个平台的专辑
    final allAlbums = [...spotifyAlbums, ...youtubeAlbums];
    
    // 按名称排序
    allAlbums.sort((a, b) => a.name.compareTo(b.name));
    
    state = AsyncValue.data(FavoriteAlbumsState(
      items: allAlbums,
      hasMore: spotifyAlbumsState.hasMore, // 只考虑 Spotify 的分页
    ));
  }
  // 加载更多
  Future<void> fetchMore() async {
    if (state.value == null || state.value!.isLoading || !state.value!.hasMore) return;

    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    
    try {
      if (_currentPlatform == MusicPlatform.spotify) {
        await _loadMoreSpotifyAlbums();
      } else if (_currentPlatform == MusicPlatform.youtubeMusic) {
        await _loadMoreYoutubeMusicAlbums();
      } else if (_currentPlatform == MusicPlatform.mixed) {
        // 混合模式下，只加载更多 Spotify 专辑
        await _loadMoreMixedAlbums();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  // 加载更多混合模式的专辑
  Future<void> _loadMoreMixedAlbums() async {
    // 在混合模式下，我们只加载更多 Spotify 专辑
    final currentAlbums = state.value!.items;
    
    // 加载更多 Spotify 专辑
    final spotifyNotifier = ref.read(favoriteAlbumsProvider.notifier);
    await spotifyNotifier.fetchMore();
    
    final spotifyAlbumsState = await ref.read(favoriteAlbumsProvider.future);
    final spotifyAlbums = spotifyAlbumsState.items.map(_convertSpotifyAlbum).toList();
    
    // 找出新加载的 Spotify 专辑
    final existingIds = currentAlbums.map((e) => e.id).toSet();
    final newSpotifyAlbums = spotifyAlbums.where((album) => !existingIds.contains(album.id)).toList();
    
    // 合并并排序
    final allAlbums = [...currentAlbums, ...newSpotifyAlbums];
    allAlbums.sort((a, b) => a.name.compareTo(b.name));
    
    state = AsyncValue.data(FavoriteAlbumsState(
      items: allAlbums,
      hasMore: spotifyAlbumsState.hasMore,
      isLoading: false,
    ));
  }
  // Spotify 专辑加载
  Future<void> _loadSpotifyAlbums() async {
    final spotifyAlbumsState = await ref.read(favoriteAlbumsProvider.future);
    final albums = spotifyAlbumsState.items.map(_convertSpotifyAlbum).toList();
    
    state = AsyncValue.data(FavoriteAlbumsState(
      items: albums,
      hasMore: spotifyAlbumsState.hasMore,
    ));
  }
  // 加载更多 Spotify 专辑
  Future<void> _loadMoreSpotifyAlbums() async {
    final spotifyNotifier = ref.read(favoriteAlbumsProvider.notifier);
    await spotifyNotifier.fetchMore();
    
    final spotifyAlbumsState = await ref.read(favoriteAlbumsProvider.future);
    final albums = spotifyAlbumsState.items.map(_convertSpotifyAlbum).toList();
    
    state = AsyncValue.data(FavoriteAlbumsState(
      items: albums,
      hasMore: spotifyAlbumsState.hasMore,
    ));
  }
  // YouTube Music 专辑加载
  Future<void> _loadYoutubeMusicAlbums() async {
    final library = await ref.read(youtubeMusicUserLibraryProvider.future);
    final albums = library.albums.map(_convertYouTubeMusicAlbum).toList();
    
    state = AsyncValue.data(FavoriteAlbumsState(
      items: albums,
      hasMore: false, // YouTube Music API 可能不支持分页
    ));
  }
  // 加载更多 YouTube Music 专辑
  Future<void> _loadMoreYoutubeMusicAlbums() async {
    // YouTube Music API 可能不支持分页，这里是占位实现
    state = AsyncValue.data(state.value!.copyWith(isLoading: false));
  }
  // 转换 Spotify 专辑到通用 Album
  Album _convertSpotifyAlbum(AlbumSimple spotifyAlbum) {
    return Album(
      id: spotifyAlbum.id!,
      name: spotifyAlbum.name!,
      uri: spotifyAlbum.uri!,
      description: null,
      imageUrl: spotifyAlbum.images?.firstOrNull?.url,
      releaseDate: spotifyAlbum.releaseDate != null 
          ? DateTime.tryParse(spotifyAlbum.releaseDate!) 
          : null,
      artists: spotifyAlbum.artists?.map((a) => a.name!).toList(),
      albumType: spotifyAlbum.albumType?.name,
      platformMetadata: {
        'platform': 'spotify',
        'href': spotifyAlbum.href,
        'type': spotifyAlbum.type,
      },
    );
  }
  // 转换 YouTube Music 专辑到通用 Album
  Album _convertYouTubeMusicAlbum(YoutubeMusicAlbum ytAlbum) {
    return Album(
      id: ytAlbum.id,
      name: ytAlbum.title,
      uri: 'youtube:album:${ytAlbum.id}',
      description: ytAlbum.description,
      imageUrl: ytAlbum.thumbnailUrl,
      releaseDate: ytAlbum.releaseDate,
      artists: [ytAlbum.artistName],
      albumType: 'album',
      platformMetadata: {
        'platform': 'youtube_music',
        'artistId': ytAlbum.artistId,
      },
    );
  }

  // 添加收藏专辑方法
  Future<void> addFavorite(String albumId) async {
    try {
      if (_currentPlatform == MusicPlatform.spotify || _currentPlatform == MusicPlatform.mixed) {
        // 使用 Spotify 的收藏方法
        await ref.read(favoriteAlbumsProvider.notifier).addFavorites([albumId]);
      }
      
      if (_currentPlatform == MusicPlatform.youtubeMusic || _currentPlatform == MusicPlatform.mixed) {
        // 使用 YouTube Music 的收藏方法
        final ytService = ref.read(youtubeMusicProvider);
        // YouTube Music 确实支持添加专辑到库
        await ytService.addToLibrary("ALBUM", albumId);
      }
      
      // 重新加载专辑列表以反映变化
      await loadAlbums();
    } catch (e) {
      // 处理错误
    }
  }

  // 取消收藏专辑方法
  Future<void> removeFavorite(String albumId) async {
    try {
      if (_currentPlatform == MusicPlatform.spotify || _currentPlatform == MusicPlatform.mixed) {
        // 使用 Spotify 的取消收藏方法
        await ref.read(favoriteAlbumsProvider.notifier).removeFavorites([albumId]);
      }
      
      if (_currentPlatform == MusicPlatform.youtubeMusic || _currentPlatform == MusicPlatform.mixed) {
        // 使用 YouTube Music 的取消收藏方法
        final ytService = ref.read(youtubeMusicProvider);
        // YouTube Music 确实支持从库中移除专辑
        await ytService.removeFromLibrary("ALBUM", albumId);
      }
      
      // 重新加载专辑列表以反映变化
      await loadAlbums();
    } catch (e) {
      // 处理错误
    }
  }
}

// 通用专辑提供者
final unifiedFavoriteAlbumsProvider = StateNotifierProvider<FavoriteAlbumsNotifier, AsyncValue<FavoriteAlbumsState>>((ref) {
  return FavoriteAlbumsNotifier(ref);
});

