import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/components/dialogs/select_device_dialog.dart';
import 'package:spotube/components/playbutton_card.dart';
import 'package:spotube/extensions/context.dart'; 
// 移除 Spotify 图片扩展
// import 'package:spotube/extensions/spotify/image.dart';
// 添加通用图片类型
import 'package:spotube/utils/type/image_type.dart';

import 'package:spotube/models/connect/connect.dart';
import 'package:spotube/provider/audio_player/querying_track_info.dart';
import 'package:spotube/provider/connect/connect.dart';
import 'package:spotube/provider/history/history.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/base/album.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/provider/album/album_provider.dart';
import 'package:spotube/services/navigation/navigation_service.dart';

class AlbumCard extends HookConsumerWidget {
  final Album album;
  const AlbumCard(this.album, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final playlist = ref.watch(audioPlayerProvider);
    final playing =
        useStream(audioPlayer.playingStream).data ?? audioPlayer.isPlaying;
    final playlistNotifier = ref.watch(audioPlayerProvider.notifier);
    final historyNotifier = ref.read(playbackHistoryActionsProvider);
    final isFetchingActiveTrack = ref.watch(queryingTrackInfoProvider);
    // 获取导航服务
    final navigationService = ref.watch(navigationServiceProvider);

    bool isPlaylistPlaying = useMemoized(
      () => playlist.containsCollection(album.id),
      [playlist, album.id],
    );

    final updating = useState(false);

    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    Future<List<SourceableTrack>> fetchAllTrack() async {
      if (album.tracks != null && album.tracks!.isNotEmpty) {
        return album.tracks!;
      }
      // Fix: Use select() to get the AsyncValue and then wait for it to complete
      final albumTracksState = ref.read(albumTracksProvider(album.id));
      if (albumTracksState is AsyncLoading) {
        // Wait for data to load
        await Future.delayed(const Duration(milliseconds: 100));
        return fetchAllTrack();
      }
      final tracks = await ref.read(albumTracksProvider(album.id).notifier).fetchAll();
      return tracks;
    }

    // 修改图片 URL 获取方式 - 使用 album.imageUrl 而不是 album.images
    final imageUrl = album.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.collection);
    
    final artistsStr = album.artists?.join(", ") ?? "";
    
    return PlaybuttonCard(
      imageUrl: imageUrl,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      title: album.name,
      description: "${album.albumType?.toUpperCase()} • $artistsStr",
      isPlaying: isPlaylistPlaying && playing,
      isLoading: updating.value || isFetchingActiveTrack,
      onTap: () {
        // 使用 NavigationService 导航到专辑页面
        navigationService.navigateToAlbumById(album.id);
      },
      onPlaybuttonPressed: () async {
        updating.value = true;
        try {
          if (isPlaylistPlaying) {
            return playing ? audioPlayer.pause() : audioPlayer.resume();
          }
          
          final fetchedTracks = await fetchAllTrack();
          
          if (fetchedTracks.isEmpty || !context.mounted) return;
          
          final isRemoteDevice = await showSelectDeviceDialog(context, ref);
          if (isRemoteDevice) {
            final remotePlayback = ref.read(connectProvider.notifier);
            await remotePlayback.load(
              WebSocketLoadEventData.album(
                tracks: fetchedTracks,
                collection: album,
              ),
            );
          } else {
            await playlistNotifier.load(fetchedTracks, autoPlay: true);
            playlistNotifier.addCollection(album.id);
            // Fix: Use addCollection instead of addToHistory
            historyNotifier.addCollection(album);
          }
        } finally {
          updating.value = false;
        }
      },
      onAddToQueuePressed: () async {
        if (isPlaylistPlaying) {
          return;
        }
      
        updating.value = true;
        try {
          final fetchedTracks = await fetchAllTrack();
      
          if (fetchedTracks.isEmpty) return;
          playlistNotifier.addTracks(fetchedTracks);
          playlistNotifier.addCollection(album.id);
          // Fix: Use addCollection instead of addToHistory
          historyNotifier.addCollection(album);
          if (context.mounted) {
            final snackbar = SnackBar(
              content: Text(
                context.l10n.added_to_queue(fetchedTracks.length),
              ),
              action: SnackBarAction(
                label: "Undo",
                onPressed: () {
                  playlistNotifier
                      .removeTracks(fetchedTracks.map((e) => e.id));
                },
              ),
            );
            scaffoldMessenger?.showSnackBar(snackbar);
          }
        } finally {
          updating.value = false;
        }
      },
    );
  }
}