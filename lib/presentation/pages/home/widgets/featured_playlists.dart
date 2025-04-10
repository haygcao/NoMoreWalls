import 'package:flutter/material.dart';

class FeaturedPlaylists extends StatelessWidget {
  const FeaturedPlaylists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Playlists',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Placeholder count
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _PlaylistCard(
                  title: 'Playlist ${index + 1}',
                  description: 'Curated collection of great tracks',
                  imageUrl: 'assets/placeholder.png',
                  onTap: () {
                    // Navigate to playlist details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const _PlaylistCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imageUrl,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
