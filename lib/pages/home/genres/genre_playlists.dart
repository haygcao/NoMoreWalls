import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/fake.dart';
import 'package:spotube/hooks/utils/use_custom_status_bar_color.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/modules/playlist/playlist_card.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/components/titlebar/titlebar.dart';
import 'package:spotube/components/waypoint.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:collection/collection.dart';

import 'package:spotube/utils/platform.dart';
// 添加统一的 category provider
import 'package:spotube/provider/category/category_provider.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

class GenrePlaylistsPage extends HookConsumerWidget {
  static const name = "genre_playlists";

  final dynamic category; // 使用动态类型，适应不同平台的分类对象
  final String categoryId; // 添加分类ID
  
  const GenrePlaylistsPage({
    super.key, 
    required this.category,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, ref) {
    final mediaQuery = MediaQuery.of(context);
    // 使用统一的 provider，传入分类ID
    final playlists = ref.watch(categoryPlaylistsProvider(categoryId));
    final playlistsNotifier =
        ref.read(categoryPlaylistsProvider(categoryId).notifier);
    final scrollController = useScrollController();
    final routeName = GoRouterState.of(context).name;
    final preferences = ref.watch(userPreferencesProvider);
    final audioSource = preferences.audioSource;

    useCustomStatusBarColor(
      Colors.black,
      routeName == GenrePlaylistsPage.name,
      noSetBGColor: true,
      automaticSystemUiAdjustment: false,
    );

    // 根据不同平台获取分类名称和图标URL
    String? categoryName;
    String? iconUrl;
    
    if (audioSource == AudioSource.youtube) {
      // YouTube Music 分类
      categoryName = category.title;
      iconUrl = category.thumbnailUrl;
    } else {
      // Spotify 分类
      categoryName = category.name;
      if (category.icons != null && category.icons.isNotEmpty) {
        iconUrl = category.icons.first.url;
      }
    }

    return Scaffold(
      appBar: kIsDesktop
          ? const TitleBar(
           
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            )
          : null,
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: iconUrl != null ? DecorationImage(
            image: UniversalImage.imageProvider(iconUrl),
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
            repeat: ImageRepeat.noRepeat,
            matchTextDirection: true,
          ) : null,
        ),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: kIsMobile,
              expandedHeight: mediaQuery.mdAndDown ? 200 : 150,
              title: const Text(""),
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: kIsDesktop,
                title: Text(
                  categoryName ?? "",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      const Shadow(
                        offset: Offset(-1.5, -1.5),
                        color: Colors.black54,
                      ),
                      const Shadow(
                        offset: Offset(1.5, -1.5),
                        color: Colors.black54,
                      ),
                      const Shadow(
                        offset: Offset(1.5, 1.5),
                        color: Colors.black54,
                      ),
                      const Shadow(
                        offset: Offset(-1.5, 1.5),
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            // 其余部分保持不变
            const SliverGap(20),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: mediaQuery.mdAndDown ? 12 : 24,
                ),
                sliver: playlists.asData?.value.items.isNotEmpty != true
                    ? Skeletonizer.sliver(
                        child: SliverToBoxAdapter(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(
                              6,
                              (index) => PlaylistCard(FakeData.playlist),
                            ),
                          ),
                        ),
                      )
                    : SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 190,
                          mainAxisExtent: mediaQuery.mdAndDown ? 225 : 250,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount:
                            (playlists.asData?.value.items.length ?? 0) + 1,
                        itemBuilder: (context, index) {
                          final playlist = playlists.asData?.value.items
                              .elementAtOrNull(index);

                          if (playlist == null) {
                            if (playlists.asData?.value.hasMore == false) {
                              return const SizedBox.shrink();
                            }
                            return Skeletonizer(
                              enabled: true,
                              child: Waypoint(
                                controller: scrollController,
                                isGrid: true,
                                onTouchEdge: playlistsNotifier.fetchMore,
                                child: PlaylistCard(FakeData.playlist),
                              ),
                            );
                          }

                          return Skeleton.keep(
                            child: PlaylistCard(playlist),
                          );
                        },
                      ),
              ),
            ),
            const SliverGap(20),
          ],
        ),
      ),
    );
  }
}
