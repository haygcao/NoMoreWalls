import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/dialogs/prompt_dialog.dart';
import 'package:spotube/components/tracks_view/sections/body/use_is_user_playlist.dart';
import 'package:spotube/components/tracks_view/track_view.dart';
import 'package:spotube/components/tracks_view/track_view_props.dart';
import 'package:spotube/extensions/context.dart';
// 移除 Spotify 图片扩展
// import 'package:spotube/provider/spotify/extension/image.dart';
// 移除 Spotify 特定 provider
// import 'package:spotube/provider/spotify/spotify.dart';
// 添加通用播放列表 provider
import 'package:spotube/provider/playlist/playlist_provider.dart';
// 添加收藏播放列表 provider
import 'package:spotube/provider/playlist/favorite_playlist_provider.dart';
// 添加通用图片工具
import 'package:spotube/utils/type/image_type.dart';
// 添加通用播放列表模型
import 'package:spotube/services/base/playlist.dart';
// 添加音乐平台提供者
import 'package:spotube/provider/music_platform.dart';
// 添加导入

class PlaylistPage extends HookConsumerWidget {
  static const name = "playlist";

  final Playlist _playlist;
  const PlaylistPage({
    super.key,
    required Playlist playlist,
  }) : _playlist = playlist;

  @override
  Widget build(BuildContext context, ref) {
    // 使用通用播放列表提供者
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    
    // 使用 unifiedFavoritePlaylistsProvider 获取收藏的播放列表
    final favoritePlaylistsAsync = ref.watch(unifiedFavoritePlaylistsProvider);
    final favoritePlaylistsState = favoritePlaylistsAsync.asData?.value;
    
    final playlist = favoritePlaylistsState?.items
        .firstWhereOrNull((p) => p.id == _playlist.id) ?? _playlist;

    // 使用统一的播放列表提供者获取轨道
    final unifiedProvider = ref.watch(unifiedPlaylistProvider.notifier);
    final tracksAsync = ref.watch(
      FutureProvider.autoDispose((ref) => 
        unifiedProvider.getPlaylistTracks(currentPlatform, playlist.id)
      )
    );
    
    // 检查是否是收藏的播放列表
    final isFavoritePlaylist = favoritePlaylistsState?.items
        .any((p) => p.id == playlist.id) ?? false;

    final isUserPlaylist = useIsUserPlaylist(ref, playlist.id);

    return InheritedTrackView(
      collection: playlist,
      // 使用 MediaImageUtils 获取图片 URL
      image: playlist.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.collection),
      pagination: PaginationProps(
        hasNextPage: false, // 统一接口不支持分页
        isLoading: tracksAsync.isLoading,
        onFetchMore: () async {
          // 统一接口不支持分页加载更多
        },
        onRefresh: () async {
          // 刷新播放列表轨道
          ref.invalidate(
            FutureProvider.autoDispose((ref) => 
              unifiedProvider.getPlaylistTracks(currentPlatform, playlist.id)
            )
          );
        },
        onFetchAll: () async {
          return await unifiedProvider.getPlaylistTracks(currentPlatform, playlist.id);
        },
      ),
      title: playlist.name,
      description: playlist.description,
      tracks: tracksAsync.asData?.value ?? [],
      routePath: '/playlist/${playlist.id}',
      isLiked: isFavoritePlaylist,
      shareUrl: _getShareUrl(playlist),
      onHeart: () async {
        final confirmed = isUserPlaylist
            ? await showPromptDialog(
                context: context,
                title: context.l10n.delete_playlist,
                message: context.l10n.delete_playlist_confirmation,
              )
            : true;
        if (!confirmed) return null;

        // 使用 FavoritePlaylistsNotifier 处理收藏/取消收藏
        final favoriteNotifier = ref.read(unifiedFavoritePlaylistsProvider.notifier);
        
        if (isFavoritePlaylist) {
          // 使用统一的取消收藏方法
          final success = await favoriteNotifier.removeFromFavorites(playlist);
          return success ? false : isFavoritePlaylist;
        } else {
          // 使用统一的收藏方法
          final success = await favoriteNotifier.addToFavorites(playlist);
          return success ? true : isFavoritePlaylist;
        }
      },
      child: const TrackView(),
    );
  }
  
  // 根据平台获取分享链接
  String _getShareUrl(Playlist playlist) {
    final platform = playlist.platformMetadata?['platform'];
    
    if (platform == 'youtube_music') {
      return "https://music.youtube.com/playlist?list=${playlist.id}";
    } else {
      // 默认为 Spotify
      return playlist.platformMetadata?['externalUrls']?['spotify'] ??
          "https://open.spotify.com/playlist/${playlist.id}";
    }
  }
}
