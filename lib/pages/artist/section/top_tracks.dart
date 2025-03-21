import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
// 移除 Spotify 特定导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/collections/fake.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/dialogs/select_device_dialog.dart';
import 'package:spotube/components/track_tile/track_tile.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/connect/connect.dart';
import 'package:spotube/provider/connect/connect.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
// 替换为统一的艺术家提供者
import 'package:spotube/provider/artist/artist_provider.dart';
// 导入通用的 Track 模型
import 'package:spotube/services/base/sourceable_track.dart';

class ArtistPageTopTracks extends HookConsumerWidget {
  final String artistId;
  const ArtistPageTopTracks({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final playlist = ref.watch(audioPlayerProvider);
    final playlistNotifier = ref.watch(audioPlayerProvider.notifier);
    // 使用统一的顶部曲目提供者
    final topTracksQuery = ref.watch(unifiedArtistTopTracksProvider(artistId));

    final isPlaylistPlaying = playlist.containsTracks(
      topTracksQuery.asData?.value ?? <SourceableTrack>[],
    );

    if (topTracksQuery.hasError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(topTracksQuery.error.toString()),
        ),
      );
    }

    final topTracks = topTracksQuery.asData?.value ??
        List.generate(10, (index) => FakeData.sourceableTrack);

    // 修改 playPlaylist 方法以使用 SourceableTrack 而不是 Track
    void playPlaylist(List<SourceableTrack> tracks, {SourceableTrack? currentTrack}) async {
      currentTrack ??= tracks.first;

      final isRemoteDevice = await showSelectDeviceDialog(context, ref);
      if (isRemoteDevice) {
        final remotePlayback = ref.read(connectProvider.notifier);
        final remotePlaylist = ref.read(queueProvider);

        final isPlaylistPlaying = remotePlaylist.containsTracks(tracks);

        if (!isPlaylistPlaying) {
          // 直接使用 WebSocketLoadEventData 构造函数，而不是 playlist 工厂方法
          await remotePlayback.load(
            WebSocketLoadEventData(
              tracks: tracks,
              initialIndex: tracks.indexWhere((s) => s.id == currentTrack?.id),
            ),
          );
        } else if (isPlaylistPlaying &&
            currentTrack.id != remotePlaylist.activeTrack?.id) {
          final index = playlist.tracks
              .toList()
              .indexWhere((s) => s.id == currentTrack!.id);
          await remotePlayback.jumpTo(index);
        }
      } else {
        if (!isPlaylistPlaying) {
          playlistNotifier.load(
            tracks,
            initialIndex: tracks.indexWhere((s) => s.id == currentTrack?.id),
            autoPlay: true,
          );
        } else if (isPlaylistPlaying &&
            currentTrack.id != playlist.activeTrack?.id) {
          await playlistNotifier.jumpToTrack(currentTrack);
        }
      }
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  context.l10n.top_tracks,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (!isPlaylistPlaying)
                IconButton(
                  icon: const Icon(
                    SpotubeIcons.queueAdd,
                  ),
                  onPressed: () {
                    playlistNotifier.addTracks(topTracks.toList());
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        width: 300,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          context.l10n.added_to_queue(
                            topTracks.length,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 5),
              IconButton(
                icon: Skeleton.keep(
                  child: Icon(
                    isPlaylistPlaying ? SpotubeIcons.stop : SpotubeIcons.play,
                    color: Colors.white,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                onPressed: () => playPlaylist(topTracks.toList()),
              )
            ],
          ),
        ),
        SliverList.builder(
          itemCount: topTracks.length,
          itemBuilder: (context, index) {
            final track = topTracks.elementAt(index);
            return TrackTile(
              index: index,
              playlist: playlist,
              track: track,
              onTap: () async {
                playPlaylist(
                  topTracks.toList(),
                  currentTrack: track,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
