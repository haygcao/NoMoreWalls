import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/models/youtube_music/album.dart';
import 'package:spotube/models/youtube_music/section.dart';
import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/sourced_track/enums.dart';

class HomeNewReleasesSection extends HookConsumerWidget {
  const HomeNewReleasesSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final isYoutubeMusic = preferences.audioSource == AudioSource.youtube;

    if (isYoutubeMusic) {
      // YouTube Music 版本
      final youtubeMusicSections = ref.watch(youtubeMusicHomeSectionsProvider);
      
      return youtubeMusicSections.when(
        data: (sections) {
          // 查找新发行的专辑部分
          final newReleasesSection = sections.firstWhere(
            (section) => section.title?.toLowerCase().contains('新发行') ?? false,
            orElse: () => sections.firstWhere(
              (section) => section.title?.toLowerCase().contains('new release') ?? false,
              orElse: () => sections.isEmpty 
                  ? YoutubeMusicSection(id: '', title: '', items: [])
                  : sections.first,
            ),
          );
          
          // Check if we got a valid section
          if (newReleasesSection.items.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          
          final albums = newReleasesSection.items
              .whereType<YoutubeMusicAlbum>()
              .toList();
          
          if (albums.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
          
          return SliverToBoxAdapter(
            child: HorizontalPlaybuttonCardView<YoutubeMusicAlbum>(
              items: albums,
              title: Text(context.l10n.new_releases),
              hasNextPage: false,
              isLoadingNextPage: false,
              onFetchMore: () {},
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      );
    } else {
      // Spotify 版本 (原有代码)
      final auth = ref.watch(spotifyAuthenticationProvider);

      final newReleases = ref.watch(albumReleasesProvider);
      final newReleasesNotifier = ref.read(albumReleasesProvider.notifier);

      final albums = ref.watch(userArtistAlbumReleasesProvider);

      if (auth.asData?.value == null ||
          newReleases.isLoading ||
          newReleases.asData?.value.items.isEmpty == true) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverToBoxAdapter(
        child: HorizontalPlaybuttonCardView<Album>(
          items: albums,
          title: Text(context.l10n.new_releases),
          isLoadingNextPage: newReleases.isLoadingNextPage,
          hasNextPage: newReleases.asData?.value.hasMore ?? false,
          onFetchMore: newReleasesNotifier.fetchMore,
        ),
      );
    }
  }
}
