import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/modules/artist/artist_card.dart';
// 替换 Spotify 特定导入为通用提供者
import 'package:spotube/provider/artist/artist_provider.dart';

class ArtistPageRelatedArtists extends ConsumerWidget {
  final String artistId;
  const ArtistPageRelatedArtists({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 使用通用的相关艺术家提供者
    final relatedArtists = ref.watch(unifiedRelatedArtistsProvider(artistId));

    return switch (relatedArtists) {
      AsyncData(value: final artists) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          sliver: SliverGrid.builder(
            itemCount: artists.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 250,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final artist = artists.elementAt(index);
              return ArtistCard(artist);
            },
          ),
        ),
      AsyncError(:final error) => SliverToBoxAdapter(
          child: Center(
            child: Text(error.toString()),
          ),
        ),
      _ => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
    };
  }
}
