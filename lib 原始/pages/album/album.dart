import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 特定导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/tracks_view/track_view.dart';
import 'package:spotube/components/tracks_view/track_view_props.dart';
import 'package:spotube/extensions/context.dart';
// 移除 Spotify 特定扩展
// import 'package:spotube/provider/spotify/extension/image.dart';
// import 'package:spotube/provider/spotify/spotify.dart';

// 导入通用模型和提供者
import 'package:spotube/services/base/album.dart';
import 'package:spotube/provider/album/album_provider.dart';
import 'package:spotube/provider/album/favorite_albums_provider.dart';
// 添加 albumsIsSavedProvider 的导入
import 'package:spotube/provider/album/album_is_saved_provider.dart';
import 'package:spotube/utils/type/image_type.dart';

class AlbumPage extends HookConsumerWidget {
  static const name = "album";

  // 使用通用 Album 类型
  final Album album;
  const AlbumPage({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 使用通用专辑提供者
    final tracks = ref.watch(albumTracksProvider(album.id));
    final tracksNotifier = ref.watch(albumTracksProvider(album.id).notifier);
    // 修正 provider 名称
    final favoriteAlbumsNotifier = ref.watch(unifiedFavoriteAlbumsProvider.notifier);
    final isSavedAlbum = ref.watch(albumsIsSavedProvider(album.id));

    // 获取发行日期和艺术家名称
    final releaseDate = album.releaseDate != null 
        ? "${album.releaseDate!.year}-${album.releaseDate!.month.toString().padLeft(2, '0')}-${album.releaseDate!.day.toString().padLeft(2, '0')}"
        : "";
    final artistName = album.artists!.isNotEmpty ? album.artists?.first : "";

    return InheritedTrackView(
      collection: album,
      // 使用通用图片 URL
      image: album.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
      title: album.name,
      description:
          "${context.l10n.released} • $releaseDate • $artistName",
      tracks: tracks.asData?.value ?? [],
      pagination: PaginationProps(
        hasNextPage: false, // 专辑通常一次性加载所有曲目
        isLoading: tracks.isLoading,
        onFetchMore: () async {
          // 专辑通常不需要分页加载
        },
        onFetchAll: () async {
          return tracksNotifier.fetchAll();
        },
        onRefresh: () async {
          ref.invalidate(albumTracksProvider(album.id));
        },
      ),
      routePath: "/album/${album.id}",
      // 使用通用分享 URL，支持多平台
      shareUrl: _getShareUrl(album),
      isLiked: isSavedAlbum.asData?.value ?? false,
      onHeart: isSavedAlbum.asData?.value == null
          ? null
          : () async {
              if (isSavedAlbum.asData!.value) {
                // 修改方法名以匹配 FavoriteAlbumsNotifier 类中的方法
                await favoriteAlbumsNotifier.removeFavorite(album.id);
              } else {
                await favoriteAlbumsNotifier.addFavorite(album.id);
              }
              return null;
            },
      child: const TrackView(),
    );
  }
  
  // 根据专辑类型获取分享 URL
  String _getShareUrl(Album album) {
    // 检查是否是 YouTube Music 专辑
    if (album.platformMetadata != null && 
        album.platformMetadata!['type'] == 'youtube_music') {
      return album.platformMetadata!['externalUrls']?['youtube'] ?? 
             "https://music.youtube.com/playlist?list=${album.id}";
    }
    
    // 默认为 Spotify 专辑
    return album.platformMetadata?['externalUrls']?['spotify'] ?? 
           "https://open.spotify.com/album/${album.id}";
  }
}
