import 'package:flutter/material.dart';

import '../../../../core/providers/music_provider.dart';
import '../../../../core/base/interfaces/media/track_interface.dart';

class RecentTracks extends StatelessWidget {
  const RecentTracks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();

    if (musicProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (musicProvider.error != null) {
      return Center(child: Text(musicProvider.error!));
    }

    final tracks = musicProvider.recentTracks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Played',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return _TrackListItem(
              title: track.name,
              artist: track.artists.map((a) => a.name).join(', '),
              album: track.album?.name ?? '',
              duration:
                  '${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}',
              imageUrl: track.album?.imageUrl ?? 'assets/placeholder.png',
              onTap: () async {
                await musicProvider.playTrack(track);
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              // Navigate to full history
            },
            child: const Text('View Full History'),
          ),
        ),
      ],
    );
  }
}

class _TrackListItem extends StatelessWidget {
  final String title;
  final String artist;
  final String album;
  final String duration;
  final String imageUrl;
  final VoidCallback onTap;

  const _TrackListItem({
    Key? key,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$artist • $album',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            duration,
            style: TextStyle(color: Colors.grey[600]),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle menu item selection
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_playlist',
                child: Text('Add to Playlist'),
              ),
              const PopupMenuItem(
                value: 'add_queue',
                child: Text('Add to Queue'),
              ),
              const PopupMenuItem(
                value: 'view_artist',
                child: Text('View Artist'),
              ),
              const PopupMenuItem(
                value: 'view_album',
                child: Text('View Album'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
