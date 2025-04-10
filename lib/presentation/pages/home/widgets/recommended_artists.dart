import 'package:flutter/material.dart';

import '../../../../core/providers/music_provider.dart';
import '../../../../core/base/interfaces/media/artist_interface.dart';

class RecommendedArtists extends StatelessWidget {
  const RecommendedArtists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();

    if (musicProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (musicProvider.error != null) {
      return Center(child: Text(musicProvider.error!));
    }

    final artists = musicProvider.recommendedArtists;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Artists',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return _ArtistCard(
              name: artist.name,
              imageUrl: artist.imageUrl ?? 'assets/user-placeholder.png',
              onTap: () async {
                await musicProvider.followArtist(artist);
                // TODO: Navigate to artist details
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              // Navigate to browse artists
            },
            child: const Text('Browse More Artists'),
          ),
        ),
      ],
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const _ArtistCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
