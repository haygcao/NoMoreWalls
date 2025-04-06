import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart' hide Search;
// 正确的导入方式，as 子句在 show 之前
import 'package:spotify/spotify.dart' as spotify show SearchType;

import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';

// 我们自己的搜索类型枚举
enum SearchType {
  track,
  album,
  artist,
  playlist,
}

// 统一搜索结果状态
class UnifiedSearchState {
  final List<dynamic> items;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingNextPage;

  const UnifiedSearchState({
    this.items = const [],
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingNextPage = false,
  });

  UnifiedSearchState copyWith({
    List<dynamic>? items,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingNextPage,
  }) {
    return UnifiedSearchState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
    );
  }
}

// 统一搜索 Provider
final unifiedSearchProvider = StateNotifierProvider.family<
    UnifiedSearchNotifier, AsyncValue<UnifiedSearchState>, SearchType>(
  (ref, searchType) => UnifiedSearchNotifier(ref, searchType),
);

class UnifiedSearchNotifier
    extends StateNotifier<AsyncValue<UnifiedSearchState>> {
  final Ref ref;
  final SearchType searchType;
  String? _lastQuery;
  int _offset = 0;
  final int _limit = 20;

  UnifiedSearchNotifier(this.ref, this.searchType)
      : super(const AsyncValue.data(UnifiedSearchState()));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data(UnifiedSearchState());
      return;
    }

    _lastQuery = query;
    _offset = 0;
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      final platform = ref.read(currentMusicPlatformProvider);

      if (platform == MusicPlatform.youtubeMusic) {
        await _searchYoutubeMusic(query);
      } else if (platform == MusicPlatform.mixed) {
        await _searchMixed(query);
      } else {
        // 默认使用 Spotify
        await _searchSpotify(query);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> fetchMore() async {
    if (_lastQuery == null || state.value!.isLoadingNextPage || !state.value!.hasMore) {
      return;
    }

    state = AsyncValue.data(state.value!.copyWith(isLoadingNextPage: true));
    _offset += _limit;

    try {
      final platform = ref.read(currentMusicPlatformProvider);

      if (platform == MusicPlatform.youtubeMusic) {
        await _fetchMoreYoutubeMusic();
      } else if (platform == MusicPlatform.mixed) {
        await _fetchMoreMixed();
      } else {
        // 默认使用 Spotify
        await _fetchMoreSpotify();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Spotify 搜索
  Future<void> _searchSpotify(String query) async {
    final spotify = ref.read(spotifyProvider);
    final searchResult = await _getSpotifySearchResult(spotify, query, _offset, _limit);
    
    final items = _extractSpotifyItems(searchResult);
    final hasMore = items.length >= _limit;

    state = AsyncValue.data(UnifiedSearchState(
      items: items,
      hasMore: hasMore,
      isLoading: false,
    ));
  }

  Future<void> _fetchMoreSpotify() async {
    if (_lastQuery == null) return;

    final spotify = ref.read(spotifyProvider);
    final searchResult = await _getSpotifySearchResult(spotify, _lastQuery!, _offset, _limit);
    
    final newItems = _extractSpotifyItems(searchResult);
    final currentItems = state.value!.items;
    
    final allItems = [...currentItems, ...newItems];
    final hasMore = newItems.length >= _limit;

    state = AsyncValue.data(UnifiedSearchState(
      items: allItems,
      hasMore: hasMore,
      isLoading: false,
      isLoadingNextPage: false,
    ));
  }

  Future<dynamic> _getSpotifySearchResult(SpotifyApi spotifyApi, String query, int offset, int limit) async {
    switch (searchType) {
      case SearchType.track:
        // 使用正确的 spotify.SearchType
        return await spotifyApi.search.get(
          query, 
          types: [spotify.SearchType.track]
        ).getPage(limit, offset);
      case SearchType.album:
        return await spotifyApi.search.get(
          query, 
          types: [spotify.SearchType.album]
        ).getPage(limit, offset);
      case SearchType.artist:
        return await spotifyApi.search.get(
          query, 
          types: [spotify.SearchType.artist]
        ).getPage(limit, offset);
      case SearchType.playlist:
        return await spotifyApi.search.get(
          query, 
          types: [spotify.SearchType.playlist]
        ).getPage(limit, offset);
      default:
        throw UnimplementedError('未实现的搜索类型: $searchType');
    }
  }

  List<dynamic> _extractSpotifyItems(dynamic searchResult) {
    switch (searchType) {
      case SearchType.track:
        return searchResult.items ?? [];
      case SearchType.album:
        return searchResult.items ?? [];
      case SearchType.artist:
        return searchResult.items ?? [];
      case SearchType.playlist:
        return searchResult.items ?? [];
      default:
        return [];
    }
  }

  // YouTube Music 搜索
  Future<void> _searchYoutubeMusic(String query) async {
    final youtubeMusic = ref.read(youtubeMusicProvider);
    final searchResults = await youtubeMusic.search(query);
    
    final items = _extractYoutubeMusicItems(searchResults);
    final hasMore = false; // YouTube Music API 可能不支持分页

    state = AsyncValue.data(UnifiedSearchState(
      items: items,
      hasMore: hasMore,
      isLoading: false,
    ));
  }

  Future<void> _fetchMoreYoutubeMusic() async {
    // YouTube Music API 可能不支持分页，这里简化处理
    state = AsyncValue.data(state.value!.copyWith(
      isLoadingNextPage: false,
    ));
  }

  List<dynamic> _extractYoutubeMusicItems(dynamic searchResults) {
    switch (searchType) {
      case SearchType.track:
        return searchResults.tracks ?? [];
      case SearchType.album:
        return searchResults.albums ?? [];
      case SearchType.artist:
        return searchResults.artists ?? [];
      case SearchType.playlist:
        return searchResults.playlists ?? [];
      default:
        return [];
    }
  }

  // 混合模式搜索
  Future<void> _searchMixed(String query) async {
    // 先搜索 Spotify
    await _searchSpotify(query);
    
    try {
      // 再搜索 YouTube Music
      final youtubeMusic = ref.read(youtubeMusicProvider);
      final searchResults = await youtubeMusic.search(query);
      
      final ytItems = _extractYoutubeMusicItems(searchResults);
      final currentItems = state.value!.items;
      
      // 合并结果
      final allItems = [...currentItems, ...ytItems];
      
      state = AsyncValue.data(UnifiedSearchState(
        items: allItems,
        hasMore: state.value!.hasMore, // 保持 Spotify 的分页状态
        isLoading: false,
      ));
    } catch (e) {
      // 如果 YouTube Music 搜索失败，保持 Spotify 的结果
    }
  }

  Future<void> _fetchMoreMixed() async {
    // 混合模式下，只分页加载 Spotify 的结果
    await _fetchMoreSpotify();
  }
}