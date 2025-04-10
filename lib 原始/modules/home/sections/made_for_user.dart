import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/models/youtube_music/section.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/youtube_music/youtube_music_service.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

class HomeMadeForUserSection extends HookConsumerWidget {
  const HomeMadeForUserSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    // Change this line to check for audioSource instead of youtubeApiEnabled
    final isYoutubeMusic = preferences.audioSource == AudioSource.youtube;

    if (isYoutubeMusic) {
      // YouTube Music version
      // Update to use the correct provider name
      final youtubeMusicSections = ref.watch(youtubeMusicHomeSectionsProvider);
      
      return youtubeMusicSections.when(
        data: (sections) {
          // 查找推荐的播放列表部分
          final recommendedSection = sections.firstWhere(
            (section) => section.title?.toLowerCase().contains('推荐') ?? false,
            orElse: () => sections.firstWhere(
              (section) => section.title?.toLowerCase().contains('为你推荐') ?? false,
              orElse: () => sections.isEmpty ? YoutubeMusicSection(id: '', items: []) : sections.first,
            ),
          );
          
          final playlists = recommendedSection.items
              .whereType<YoutubeMusicPlaylist>()
              .toList();
          
          if (playlists.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
          
          return SliverList.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return HorizontalPlaybuttonCardView<YoutubeMusicPlaylist>(
                items: playlists,
                title: Text(recommendedSection.title ?? "为你推荐"),
                hasNextPage: false,
                isLoadingNextPage: false,
                onFetchMore: () {},
              );
            },
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SliverToBoxAdapter(
          child: Center(child: Text("加载失败: $error")),
        ),
      );
    } else {
      // Spotify 版本 (原有代码)
      final madeForUser = ref.watch(viewProvider("made-for-x-hub"));

      return SliverList.builder(
        itemCount: madeForUser.asData?.value["content"]?["items"]?.length ?? 0,
        itemBuilder: (context, index) {
          final item = madeForUser.asData?.value["content"]?["items"]?[index];
          final playlists = item["content"]?["items"]
                  ?.where((itemL2) => itemL2["type"] == "playlist")
                  .map((itemL2) => PlaylistSimple.fromJson(itemL2))
                  .toList()
                  .cast<PlaylistSimple>() ??
              <PlaylistSimple>[];
          if (playlists.isEmpty) return const SizedBox.shrink();
          return HorizontalPlaybuttonCardView<PlaylistSimple>(
            items: playlists,
            title: Text(item["name"] ?? ""),
            hasNextPage: false,
            isLoadingNextPage: false,
            onFetchMore: () {},
          );
        },
      );
    }
  }
}
