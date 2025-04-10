import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/fake.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/fallbacks/anonymous_fallback.dart';
import 'package:spotube/modules/artist/artist_card.dart';
import 'package:spotube/components/inter_scrollbar/inter_scrollbar.dart';
import 'package:spotube/components/waypoint.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/artist/favorite_artists_provider.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/services/base/base_models.dart';
//import 'package:spotube/provider/playlist/playlist_provider.dart'; // 新增统一的艺术家提供者

class UserArtists extends HookConsumerWidget {
  const UserArtists({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final auth = ref.watch(authenticationProvider);
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    final artistQuery = ref.watch(unifiedFavoriteArtistsProvider);
    final artistQueryNotifier = ref.watch(unifiedFavoriteArtistsProvider.notifier);

    final searchText = useState('');

    // 设置当前平台
    useEffect(() {
      artistQueryNotifier.setPlatform(currentPlatform);
      return null;
    }, [currentPlatform]);

    final filteredArtists = useMemoized(() {
      final artists = artistQuery.asData?.value.items ?? [];

      if (searchText.value.isEmpty) {
        return artists.toList();
      }
      return artists
          .map((e) => (
                weightedRatio(e.name, searchText.value),
                e,
              ))
          .sorted((a, b) => b.$1.compareTo(a.$1))
          .where((e) => e.$1 > 50)
          .map((e) => e.$2)
          .toList();
    }, [artistQuery.asData?.value?.items, searchText.value]);

    final controller = useScrollController();

    // 修复认证检查
    if (auth[currentPlatform]?.asData?.value == null) {
      return const AnonymousFallback();
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // 平台选择器
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SegmentedButton<MusicPlatform>(
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
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  artistQueryNotifier.loadArtists();
                },
                child: InterScrollbar(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomScrollView(
                      controller: controller,
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          flexibleSpace: SearchBar(
                            onChanged: (value) => searchText.value = value,
                            leading: const Icon(SpotubeIcons.filter),
                            hintText: context.l10n.filter_artist,
                          ),
                        ),
                        const SliverGap(10),
                        SliverLayoutBuilder(builder: (context, constrains) {
                          return SliverGrid.builder(
                            itemCount: filteredArtists.isEmpty
                                ? 6
                                : filteredArtists.length + 1,
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              mainAxisExtent: constrains.smAndDown ? 225 : 250,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              if (filteredArtists.isNotEmpty &&
                                  index == filteredArtists.length) {
                                if (artistQuery.asData?.value.hasMore != true) {
                                  return const SizedBox.shrink();
                                }

                                return Waypoint(
                                  controller: controller,
                                  isGrid: true,
                                  onTouchEdge: artistQueryNotifier.fetchMore,
                                  child: Skeletonizer(
                                    enabled: true,
                                    // 修复类型不匹配问题
                                    child: ArtistCard(FakeData.artistFake),
                                  ),
                                );
                              }

                              return Skeletonizer(
                                enabled: artistQuery.isLoading,
                                child: ArtistCard(
                                  // 修复类型不匹配问题
                                  (filteredArtists.elementAtOrNull(index) ??
                                      FakeData.artistFake),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
