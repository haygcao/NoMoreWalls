import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class HomeFeaturedSection extends HookConsumerWidget {
  const HomeFeaturedSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final audioSource = preferences.audioSource;
    
    // 根据音源选择不同的数据提供者
    if (audioSource == AudioSource.youtube) {
      // YouTube Music 精选内容
      return _YoutubeMusicFeaturedSection();
    } else {
      // Spotify 精选内容
      return _SpotifyFeaturedSection();
    }
  }
}

// Spotify 精选内容组件
class _SpotifyFeaturedSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    final featuredPlaylists = ref.watch(featuredPlaylistsProvider);
    final featuredPlaylistsNotifier =
        ref.watch(featuredPlaylistsProvider.notifier);

    return Skeletonizer(
      enabled: featuredPlaylists.isLoading,
      child: HorizontalPlaybuttonCardView<PlaylistSimple>(
        items: featuredPlaylists.asData?.value.items ?? [],
        title: Text(context.l10n.featured),
        isLoadingNextPage: featuredPlaylists.isLoadingNextPage,
        hasNextPage: featuredPlaylists.asData?.value.hasMore ?? false,
        onFetchMore: featuredPlaylistsNotifier.fetchMore,
      ),
    );
  }
}

// YouTube Music 精选内容组件
class _YoutubeMusicFeaturedSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    // 创建一个 provider 来获取 YouTube Music 的精选播放列表
    final youtubeFeaturedPlaylists = ref.watch(youtubeMusicCategoriesProvider);
    
    return Skeletonizer(
      enabled: youtubeFeaturedPlaylists.isLoading,
      child: HorizontalPlaybuttonCardView<YoutubeMusicPlaylist>(
        items: youtubeFeaturedPlaylists.asData?.value
            .take(10)
            .map((category) => 
              // 将分类转换为播放列表格式以便显示
              YoutubeMusicPlaylist(
                id: category.id,
                title: category.title,
                thumbnailUrl: category.thumbnailUrl ?? 'https://via.placeholder.com/150',
                authorId: '',
                authorName: '',
                tracks: [],
                trackCount: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
            ).toList() ?? [],
        title: Text(context.l10n.featured),
        isLoadingNextPage: false,
        hasNextPage: false,
        onFetchMore: () {},
      ),
    );
  }
}
