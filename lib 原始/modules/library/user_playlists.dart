import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:collection/collection.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:spotify/spotify.dart';
import 'package:spotube/collections/fake.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/modules/playlist/playlist_create_dialog.dart';
import 'package:spotube/components/inter_scrollbar/inter_scrollbar.dart';
import 'package:spotube/components/fallbacks/anonymous_fallback.dart';
import 'package:spotube/modules/playlist/playlist_card.dart';
import 'package:spotube/components/waypoint.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/services/navigation/navigation_service.dart';


import 'package:spotube/utils/platform.dart';


import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/playlist/favorite_playlist_provider.dart';

class UserPlaylists extends HookConsumerWidget {
  const UserPlaylists({super.key});
  
  @override
  Widget build(BuildContext context, ref) {
    final searchText = useState('');
    final auth = ref.watch(authenticationProvider);
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    
    // 使用统一的播放列表提供者
    final playlistsQuery = ref.watch(unifiedFavoritePlaylistsProvider);
    final playlistsQueryNotifier = ref.watch(unifiedFavoritePlaylistsProvider.notifier);
    final navigationService = ref.watch(navigationServiceProvider);
    
    final likedTracksPlaylist = useMemoized(
      () => PlaylistSimple()
        ..name = context.l10n.liked_tracks
        ..description = context.l10n.liked_tracks_description
        ..type = "playlist"
        ..collaborative = false
        ..public = false
        ..id = "user-liked-tracks"
        ..images = [
          Image()
            ..height = 300
            ..width = 300
            ..url = "assets/liked-tracks.jpg"
        ],
      [context.l10n],
    );
    
    final playlists = useMemoized(
      () {
        final List<dynamic> allPlaylists = [
          likedTracksPlaylist,
          ...?playlistsQuery.asData?.value.items,
        ];
    
        if (searchText.value.isEmpty) {
          return allPlaylists;
        }
    
        return allPlaylists
            .map((e) {
              final name = e is PlaylistSimple ? e.name! : (e as Playlist).name;
              return (weightedRatio(name!, searchText.value), e);
            })
            .sorted((a, b) => b.$1.compareTo(a.$1))
            .where((e) => e.$1 > 50)
            .map((e) => e.$2)
            .toList();
      },
      [playlistsQuery, searchText.value],
    );
    
    final controller = useScrollController();
    
    // 检查当前平台的认证状态
    if (auth[currentPlatform]?.asData?.value == null) {
      return const AnonymousFallback();
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        playlistsQueryNotifier.loadPlaylists();
      },
      child: SafeArea(
        child: InterScrollbar(
          controller: controller,
          child: CustomScrollView(
            controller: controller,
            slivers: [
              SliverAppBar(
                floating: true,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SearchBar(
                    onChanged: (value) => searchText.value = value,
                    hintText: context.l10n.filter_playlists,
                    leading: const Icon(SpotubeIcons.filter),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize:
                      Size.fromHeight(kIsDesktop ? 35 : kToolbarHeight),
                  child: Row(
                    children: [
                      const Gap(10),
                      // 添加平台选择器
                      SegmentedButton<MusicPlatform>(
                        segments: const [
                          ButtonSegment(
                            value: MusicPlatform.spotify,
                            label: Text('Spotify'),
                            icon: Icon(SpotubeIcons.spotify),
                          ),
                          ButtonSegment(
                            value: MusicPlatform.youtubeMusic,
                            label: Text('YouTube Music'),
                            icon: Icon(SpotubeIcons.youtube),
                          ),
                          ButtonSegment(
                            value: MusicPlatform.mixed,
                            label: Text('Mixed'),
                            icon: Icon(Icons.all_inclusive),
                          ),
                        ],
                        selected: {currentPlatform},
                        onSelectionChanged: (Set<MusicPlatform> selection) {
                          ref.read(currentMusicPlatformProvider.notifier).state = selection.first;
                        },
                      ),
                      const Gap(10),
                      const PlaylistCreateDialogButton(),
                      const Gap(10),
                      ElevatedButton.icon(
                        icon: const Icon(SpotubeIcons.magic),
                        label: Text(context.l10n.generate_playlist),
                        onPressed: () {
                          navigationService.router.pushNamed("playlist-generator");
                        },
                      ),
                      const Gap(10),
                    ],
                  ),
                ),
              ),
              const SliverGap(10),
              SliverLayoutBuilder(builder: (context, constrains) {
                return SliverGrid.builder(
                  itemCount: playlists.isEmpty ? 6 : playlists.length + 1,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: constrains.smAndDown ? 225 : 250,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    if (playlists.isNotEmpty && index == playlists.length) {
                      if (playlistsQuery.asData?.value.hasMore != true) {
                        return const SizedBox.shrink();
                      }

                      return Waypoint(
                        controller: controller,
                        isGrid: true,
                        onTouchEdge: playlistsQueryNotifier.fetchMore,
                        child: Skeletonizer(
                          enabled: true,
                          child: PlaylistCard(FakeData.playlist),
                        ),
                      );
                    }

                    return PlaylistCard(
                      playlists.elementAtOrNull(index) ??
                          FakeData.playlistSimple,
                    );
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
