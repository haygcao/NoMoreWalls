import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';

/// 统一的分类提供者，提供流派列表
/// 直接使用各平台原生的分类数据，不创建统一模型
final categoryGenresProvider = FutureProvider<List<dynamic>>((ref) async {
  final preferences = ref.watch(userPreferencesProvider);
  final audioSource = preferences.audioSource;
  
  if (audioSource == AudioSource.youtube) {
    // 直接使用 YouTube Music 的分类 provider
    return ref.watch(youtubeMusicCategoriesProvider.future);
  } else {
    // 直接使用 Spotify 的分类 API
    final spotify = ref.read(spotifyProvider);
    // 正确获取分类列表
    final categories = await spotify.categories.list().getPage(0, 50);
    // 将 Iterable<Category>? 转换为 List<dynamic>
    return categories.items?.toList() ?? [];
  }
});

/// 统一的分类播放列表提供者
/// 根据当前音乐平台和分类ID获取相应的播放列表
final categoryPlaylistsProvider = StateNotifierProvider.family<CategoryPlaylistsNotifier, AsyncValue<PlaylistsPage>, String>(
  (ref, categoryId) {
    final preferences = ref.watch(userPreferencesProvider);
    final audioSource = preferences.audioSource;
    
    return CategoryPlaylistsNotifier(ref, categoryId, audioSource);
  },
);

class CategoryPlaylistsNotifier extends StateNotifier<AsyncValue<PlaylistsPage>> {
  final Ref _ref;
  final String _categoryId;
  final AudioSource _audioSource;
  int _page = 0;
  static const _limit = 20;
  
  CategoryPlaylistsNotifier(this._ref, this._categoryId, this._audioSource) : super(const AsyncValue.loading()) {
    fetchInitial();
  }
  
  Future<void> fetchInitial() async {
    _page = 0;
    state = const AsyncValue.loading();
    await _fetchPlaylists();
  }
  
  Future<void> fetchMore() async {
    if (state.asData?.value.hasMore == false) return;
    _page++;
    await _fetchPlaylists(isMore: true);
  }
  
  Future<void> _fetchPlaylists({bool isMore = false}) async {
    try {
      final result = await _fetchPlaylistsFromPlatform();
      
      if (isMore) {
        final currentItems = state.asData!.value.items;
        state = AsyncValue.data(
          PlaylistsPage(
            items: [...currentItems, ...result.items],
            hasMore: result.hasMore,
          ),
        );
      } else {
        state = AsyncValue.data(result);
      }
    } catch (e, stack) {
      if (isMore) {
        _page--;
      }
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<PlaylistsPage> _fetchPlaylistsFromPlatform() async {
    if (_audioSource == AudioSource.youtube) {
      // 直接使用 YouTube Music 的分类播放列表 provider
      final playlists = await _ref.read(youtubeMusicCategoryPlaylistsProvider(_categoryId).future);
      
      return PlaylistsPage(
        items: playlists,
        hasMore: false, // YouTube Music API 目前不支持分页
      );
    } else {
      // 直接使用 Spotify 的分类播放列表 API
      final spotify = _ref.read(spotifyProvider);
      // 正确获取分类播放列表
      final playlistsPage = await spotify.playlists.getByCategoryId(_categoryId)
          .getPage(_page, _limit);
      
      // 将 Iterable<PlaylistSimple>? 转换为 List<dynamic>
      final items = playlistsPage.items?.toList() ?? [];
      
      return PlaylistsPage(
        items: items,
        hasMore: items.length == _limit,
      );
    }
  }
}

/// 播放列表分页模型 - 仅用于内部状态管理，不作为统一模型
class PlaylistsPage {
  final List<dynamic> items;
  final bool hasMore;
  
  const PlaylistsPage({
    required this.items,
    required this.hasMore,
  });
}
