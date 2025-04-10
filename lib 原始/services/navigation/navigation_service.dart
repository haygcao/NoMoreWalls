import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/collections/routes.dart';
import 'package:spotube/pages/album/album.dart';
import 'package:spotube/pages/artist/artist.dart';
import 'package:spotube/pages/lyrics/lyrics.dart'; // 添加歌词页面导入
import 'package:spotube/pages/playlist/playlist.dart';
import 'package:spotube/pages/settings/settings.dart';
import 'package:spotube/pages/track/track.dart';


import 'package:spotube/services/base/sourceable_track.dart';

/// 导航服务，处理应用内所有页面跳转
class NavigationService {
  final GoRouter router;
  
  NavigationService(this.router);
  
  /// 导航到歌曲详情页
  void navigateToTrack(SourceableTrack track) {
    // 不需要区分平台，直接导航到 TrackPage
    router.pushNamed(
      TrackPage.name,
      pathParameters: {'id': track.id},
    );
  }
  
  /// 导航到专辑页面
  void navigateToAlbum(AlbumSimple album) {
    router.pushNamed(
      AlbumPage.name,
      pathParameters: {'id': album.id!},
      extra: album,
    );
  }
  // 添加一个新方法，只接收专辑ID
  void navigateToAlbumById(String albumId) {
    router.pushNamed(
      AlbumPage.name,
      pathParameters: {'id': albumId},
    );
  }
  
  /// 导航到播放列表页面
  void navigateToPlaylist(PlaylistSimple playlist) {
    router.pushNamed(
      PlaylistPage.name,
      pathParameters: {'id': playlist.id!},
      extra: playlist,
    );
  }
  /// 通过ID导航到播放列表页面
  void navigateToPlaylistById(String playlistId) {
    router.pushNamed(
      PlaylistPage.name,
      pathParameters: {'id': playlistId},
    );
  }
  
  /// 导航到艺术家页面
  void navigateToArtist(String artistId) {
    router.pushNamed(
      ArtistPage.name,
      pathParameters: {'id': artistId},
    );
  }
  
  /// 导航到设置页面
  void navigateToSettings() {
    router.pushNamed(SettingsPage.name);
  }
  
   /// 导航到歌词页面
  void navigateToLyrics({bool isModal = false, BuildContext? context}) {
    if (isModal && context != null) {
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        backgroundColor: Colors.black38,
        barrierColor: Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        builder: (context) {
          // 直接使用 LyricsPage 组件
          return const LyricsPage(isModal: true);
        },
      );
    } else {
      router.pushNamed(LyricsPage.name);
    }
  }
  
  /// 导航到流派页面
  void navigateToGenres() {
    router.pushNamed("genres");
  }
  
  /// 导航到流派播放列表页面
  void navigateToGenrePlaylists(Category category) {
    router.pushNamed(
      "genre-playlists",
      pathParameters: {
        "categoryId": category.id!,
      },
      extra: category,
    );
  }
  /// 导航到统计-分钟页面
  void navigateToStatsMinutes() {
    router.pushNamed("stats-minutes");
  }
  
  /// 导航到统计-流媒体页面
  void navigateToStatsStreams() {
    router.pushNamed("stats-streams");
  }
  
  /// 导航到统计-费用页面
  void navigateToStatsStreamFees() {
    router.pushNamed("stats-stream-fees");
  }
  
  /// 导航到统计-艺术家页面
  void navigateToStatsArtists() {
    router.pushNamed("stats-artists");
  }
  
  /// 导航到统计-专辑页面
  void navigateToStatsAlbums() {
    router.pushNamed("stats-albums");
  }
  
  /// 导航到统计-播放列表页面
  void navigateToStatsPlaylists() {
    router.pushNamed("stats-playlists");
  }
  
  /// 导航到播放列表生成器页面
  void navigateToPlaylistGenerator() {
    router.pushNamed("playlist-generator");
  }
  
  /// 导航到个人资料页面
  void navigateToProfile() {
    router.pushNamed("profile");
  }
  
  /// 导航到主页Feed部分
  void navigateToHomeFeedSection(String feedId) {
    router.pushNamed(
      "home-feed-section",
      pathParameters: {
        "feedId": feedId,
      },
    );
  }
  /// 导航到本地库页面
  void navigateToLocalLibrary(String folder, {bool isDownload = false, bool isCache = false}) {
    router.pushNamed(
      "local-library",
      queryParameters: {
        if (isDownload) "downloads": "true",
        if (isCache) "cache": "true",
      },
      extra: folder,
    );
  }
}

/// 提供导航服务的Provider
final navigationServiceProvider = Provider((ref) {
  final router = ref.watch(routerProvider);
  return NavigationService(router);
});