import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/fake.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/modules/album/album_card.dart';
import 'package:spotube/components/inter_scrollbar/inter_scrollbar.dart';
import 'package:spotube/components/fallbacks/anonymous_fallback.dart';
import 'package:spotube/components/waypoint.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/album/favorite_albums_provider.dart';
import 'package:spotube/provider/music_platform.dart';

class UserAlbums extends HookConsumerWidget {
  const UserAlbums({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final auth = ref.watch(authenticationProvider);
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    final albumsQuery = ref.watch(unifiedFavoriteAlbumsProvider);
    final albumsQueryNotifier = ref.watch(unifiedFavoriteAlbumsProvider.notifier);

    final controller = useScrollController();
    final searchText = useState('');

    // 设置当前平台
    useEffect(() {
      albumsQueryNotifier.setPlatform(currentPlatform);
      return null;
    }, [currentPlatform]);

    final albums = useMemoized(() {
      if (searchText.value.isEmpty) {
        return albumsQuery.asData?.value.items ?? [];
      }
      return albumsQuery.asData?.value.items
              .map((e) => (
                    weightedRatio(e.name, searchText.value),
                    e,
                  ))
              .sorted((a, b) => b.$1.compareTo(a.$1))
              .where((e) => e.$1 > 50)
              .map((e) => e.$2)
              .toList() ??
          [];
    }, [albumsQuery.asData?.value, searchText.value]);

    // 检查当前平台的认证状态
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
                    value: MusicPlatform.mixed,  // 添加混合模式
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
                  albumsQueryNotifier.loadAlbums();
                },
                child: InterScrollbar(
                  controller: controller,
                  child: CustomScrollView(
                    controller: controller,
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        flexibleSpace: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SearchBar(
                            onChanged: (value) => searchText.value = value,
                            leading: const Icon(SpotubeIcons.filter),
                            hintText: context.l10n.filter_albums,
                          ),
                        ),
                      ),
                      const SliverGap(10),
                      SliverLayoutBuilder(builder: (context, constrains) {
                        return SliverGrid.builder(
                          itemCount: albums.isEmpty ? 6 : albums.length + 1,
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisExtent: constrains.smAndDown ? 225 : 250,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            if (albums.isNotEmpty && index == albums.length) {
                              if (albumsQuery.asData?.value.hasMore != true) {
                                return const SizedBox.shrink();
                              }

                              return Waypoint(
                                controller: controller,
                                isGrid: true,
                                onTouchEdge: albumsQueryNotifier.fetchMore,
                                child: Skeletonizer(
                                  enabled: true,
                                  child: AlbumCard(FakeData.album),
                                ),
                              );
                            }

                            return Skeletonizer(
                              enabled: albumsQuery.isLoading,
                              child: AlbumCard(
                                albums.elementAtOrNull(index) ?? FakeData.album,
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
          ],
        ),
      ),
    );
  }
}
