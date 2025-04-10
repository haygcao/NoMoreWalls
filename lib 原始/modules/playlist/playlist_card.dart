import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/dialogs/select_device_dialog.dart';
import 'package:spotube/components/playbutton_card.dart';
import 'package:spotube/extensions/context.dart';
// 移除 Spotify 特定的扩展
// import 'package:spotube/extensions/spotify/image.dart';
import 'package:spotube/models/connect/connect.dart';
import 'package:spotube/provider/audio_player/querying_track_info.dart';
import 'package:spotube/provider/connect/connect.dart';
import 'package:spotube/provider/history/history.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
// 移除 Spotify 特定的 provider
// import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/navigation/navigation_service.dart';
// 添加通用的 playlist provider
import 'package:spotube/provider/playlist/playlist_provider.dart';
import 'package:spotube/provider/music_platform.dart';
// 添加通用的用户信息 provider
import 'package:spotube/provider/user/user_provider.dart';
// 添加通用的图片工具
import 'package:spotube/utils/type/image_type.dart';
// 添加通用的 playlist 和 track 模型
import 'package:spotube/services/base/playlist.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class PlaylistCard extends HookConsumerWidget {
  // 修改为通用的 Playlist 类型
  final Playlist playlist;
  const PlaylistCard(
    this.playlist, {
    super.key,
  });
  @override
  Widget build(BuildContext context, ref) {
    final playlistQueue = ref.watch(audioPlayerProvider);
    final playlistNotifier = ref.watch(audioPlayerProvider.notifier);
    final isFetchingActiveTrack = ref.watch(queryingTrackInfoProvider);
    final historyNotifier = ref.read(playbackHistoryActionsProvider);
    // 获取当前音乐平台
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    // 获取导航服务
    final navigationService = ref.watch(navigationServiceProvider);

    final playing =
        useStream(audioPlayer.playingStream).data ?? audioPlayer.isPlaying;
    bool isPlaylistPlaying = useMemoized(
      () => playlistQueue.containsCollection(playlist.id),
      [playlistQueue, playlist.id],
    );

    final updating = useState(false);
    // 使用通用的用户信息
    final me = ref.watch(currentUserProvider);

    // 使用统一的播放列表提供者获取曲目
    Future<List<SourceableTrack>> fetchInitialTracks() async {
      // 使用统一的播放列表提供者
      return await ref.read(unifiedPlaylistProvider.notifier)
          .getPlaylistTracks(currentPlatform, playlist.id);
    }

    // 获取所有曲目，这里简化为与初始曲目相同
    Future<List<SourceableTrack>> fetchAllTracks() async {
      return await fetchInitialTracks();
    }

    return PlaybuttonCard(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      title: playlist.name,
      description: playlist.description,
      // 使用通用的图片工具
      imageUrl: playlist.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.collection),
      isPlaying: isPlaylistPlaying,
      isLoading: (isPlaylistPlaying && isFetchingActiveTrack) || updating.value,
      isOwner: playlist.owner == me.asData!.value?.id &&
          me.asData!.value?.id != null,
      onTap: () {
        // 使用导航服务导航到播放列表页面
        navigationService.navigateToPlaylistById(playlist.id);
      },
      onPlaybuttonPressed: () async {
        try {
          updating.value = true;
          if (isPlaylistPlaying && playing) {
            return audioPlayer.pause();
          } else if (isPlaylistPlaying && !playing) {
            return audioPlayer.resume();
          }

          final fetchedInitialTracks = await fetchInitialTracks();

          if (fetchedInitialTracks.isEmpty || !context.mounted) return;

          final isRemoteDevice = await showSelectDeviceDialog(context, ref);
          if (isRemoteDevice) {
            final remotePlayback = ref.read(connectProvider.notifier);
            final allTracks = await fetchAllTracks();
            await remotePlayback.load(
              WebSocketLoadEventData(
                tracks: allTracks,
                collectionId: playlist.id,
                collection: playlist.toJson(),
              ),
            );
          } else {
            await playlistNotifier.load(fetchedInitialTracks, autoPlay: true);
            playlistNotifier.addCollection(playlist.id);
            // 使用 addCollections 而不是 addPlaylists
            historyNotifier.addCollections([playlist]);

            final allTracks = await fetchAllTracks();

            // 如果有更多曲目，添加到队列
            if (allTracks.length > fetchedInitialTracks.length) {
              await playlistNotifier
                  .addTracks(allTracks.sublist(fetchedInitialTracks.length));
            }
          }
        } finally {
          if (context.mounted) {
            updating.value = false;
          }
        }
      },
      onAddToQueuePressed: () async {
        updating.value = true;
        try {
          if (isPlaylistPlaying) return;

          final fetchedInitialTracks = await fetchAllTracks();

          if (fetchedInitialTracks.isEmpty) return;

          playlistNotifier.addTracks(fetchedInitialTracks);
          playlistNotifier.addCollection(playlist.id);
          // 使用 addCollections 而不是 addPlaylists
          historyNotifier.addCollections([playlist]);
          if (context.mounted) {
            final snackbar = SnackBar(
              content: Text(context.l10n
                  .added_num_tracks_to_queue(fetchedInitialTracks.length)),
              action: SnackBarAction(
                label: "Undo",
                onPressed: () {
                  playlistNotifier
                      .removeTracks(fetchedInitialTracks.map((e) => e.id));
                },
              ),
            );
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackbar);
          }
        } finally {
          updating.value = false;
        }
      },
    );
  }
}
