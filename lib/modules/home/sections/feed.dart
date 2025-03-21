import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/spotify/views/home.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/services/navigation/navigation_service.dart';

class HomePageFeedSection extends HookConsumerWidget {
  const HomePageFeedSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final audioSource = preferences.audioSource;
    
    // 根据音源选择不同的数据提供者
    if (audioSource == AudioSource.youtube) {
      return _YoutubeMusicFeedSection();
    } else {
      return _SpotifyFeedSection();
    }
  }
}

// Spotify Feed 组件
class _SpotifyFeedSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    final homeFeed = ref.watch(homeViewProvider);
    final navigationService = ref.watch(navigationServiceProvider);
    
    final nonShortSections = homeFeed.asData?.value?.sections
            .where((s) => s.typename == "HomeGenericSectionData")
            .toList() ??
        [];

    return SliverList.builder(
      itemCount: nonShortSections.length,
      itemBuilder: (context, index) {
        final section = nonShortSections[index];
        if (section.items.isEmpty) return const SizedBox.shrink();

        return HorizontalPlaybuttonCardView(
          items: [
            for (final item in section.items)
              if (item.album != null)
                item.album!.asAlbum
              else if (item.artist != null)
                item.artist!.asArtist
              else if (item.playlist != null)
                item.playlist!.asPlaylist
          ],
          title: Text(section.title ?? context.l10n.no_title),
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
          titleTrailing: Directionality(
            textDirection: TextDirection.rtl,
            child: TextButton.icon(
              label: Text(context.l10n.browse_more),
              icon: const Icon(SpotubeIcons.angleRight),
              onPressed: () {
                navigationService.router.pushNamed(
                  "home-feed-section",
                  pathParameters: {
                    "feedId": section.uri,
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// YouTube Music Feed 组件
class _YoutubeMusicFeedSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    // 使用 YouTube Music 的首页推荐数据
    final youtubeMusicHome = ref.watch(youtubeMusicHomeProvider);
    final navigationService = ref.watch(navigationServiceProvider);
    
    // 如果数据正在加载，显示加载状态
    if (youtubeMusicHome.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    // 如果加载失败，显示错误信息
    if (youtubeMusicHome.hasError) {
      return SliverToBoxAdapter(
        child: Center(child: Text('${context.l10n.error}: ${youtubeMusicHome.error}')),
      );
    }
    
    // 获取 YouTube Music 的推荐内容
    final sections = youtubeMusicHome.asData?.value ?? [];
    
    return SliverList.builder(
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        if (section.items.isEmpty) return const SizedBox.shrink();
        
        return HorizontalPlaybuttonCardView(
          items: section.items,
          title: Text(section.title ?? context.l10n.no_title),
          hasNextPage: false,
          isLoadingNextPage: false,
          onFetchMore: () {},
          titleTrailing: Directionality(
            textDirection: TextDirection.rtl,
            child: TextButton.icon(
              label: Text(context.l10n.browse_more),
              icon: const Icon(SpotubeIcons.angleRight),
              onPressed: () {
                // 导航到 YouTube Music 的详细页面
                navigationService.router.pushNamed(
                  "youtube-music-section",
                  pathParameters: {
                    "sectionId": section.id,
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
