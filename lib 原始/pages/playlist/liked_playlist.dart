import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/tracks_view/track_view.dart';
import 'package:spotube/components/tracks_view/track_view_props.dart';
import 'package:spotube/pages/playlist/playlist.dart';
// 移除 Spotify 特定 provider
// import 'package:spotube/provider/spotify/spotify.dart';
// 添加通用播放列表模型
import 'package:spotube/services/base/playlist.dart';
// 添加通用轨道模型
import 'package:spotube/services/base/sourceable_track.dart';
// 添加通用播放列表提供者
import 'package:spotube/provider/playlist/playlist_provider.dart';
// 添加音乐平台提供者
import 'package:spotube/provider/music_platform.dart';

class LikedPlaylistPage extends HookConsumerWidget {
  static const name = PlaylistPage.name;

  final Playlist playlist;
  const LikedPlaylistPage({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 获取当前音乐平台
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    
    // 使用通用的喜欢的轨道提供者
    final likedTracksProvider = FutureProvider<List<SourceableTrack>>((ref) async {
      // 使用统一的播放列表提供者
      final unifiedProvider = ref.watch(unifiedPlaylistProvider.notifier);
      // 假设 "liked" 是一个特殊的播放列表 ID，表示喜欢的歌曲
      return await unifiedProvider.getPlaylistTracks(currentPlatform, "liked");
    });
    
    final likedTracks = ref.watch(likedTracksProvider);
    final tracks = likedTracks.asData?.value ?? <SourceableTrack>[];

    return InheritedTrackView(
      collection: playlist,
      image: "assets/liked-tracks.jpg",
      pagination: PaginationProps(
        hasNextPage: false,
        isLoading: likedTracks.isLoading,
        onFetchMore: () {},
        onFetchAll: () async {
          return tracks.toList();
        },
        onRefresh: () async {
          ref.invalidate(likedTracksProvider);
        },
      ),
      title: playlist.name,
      description: playlist.description,
      tracks: tracks,
      routePath: '/playlist/${playlist.id}',
      isLiked: false,
      shareUrl: "",
      onHeart: null,
      child: const TrackView(),
    );
  }
}
