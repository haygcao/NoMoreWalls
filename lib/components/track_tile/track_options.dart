import 'dart:io';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/collections/assets.gen.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/adaptive/adaptive_pop_sheet_list.dart';
import 'package:spotube/components/dialogs/track_details_dialog.dart';
import 'package:spotube/components/heart_button/use_track_toggle_like.dart';
import 'package:spotube/components/track_tile/track_options/track_option_values.dart';
import 'package:spotube/components/track_tile/track_options/track_options_actions.dart';
import 'package:spotube/components/track_tile/track_options/track_options_header.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/models/local_track.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/blacklist_provider.dart';
import 'package:spotube/provider/download_manager_provider.dart';
import 'package:spotube/provider/local_tracks/local_tracks_provider.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
// 移除 Spotify 依赖
// import 'package:spotube/provider/spotify/spotify.dart';
// 添加 SourceableTrack 接口
import 'package:spotube/services/base/sourceable_track.dart';
// 添加 YouTube Music 依赖
import 'package:spotube/provider/youtube_music/youtube_music.dart';
// 添加导入
import 'package:spotube/services/navigation/navigation_service.dart';

import 'package:url_launcher/url_launcher_string.dart';

class TrackOptions extends HookConsumerWidget {
  // 将 Track 类型替换为 SourceableTrack
  final SourceableTrack track;
  final bool userPlaylist;
  final String? playlistId;
  final ObjectRef<ValueChanged<RelativeRect>?>? showMenuCbRef;
  final Widget? icon;
  const TrackOptions({
    super.key,
    required this.track,
    this.showMenuCbRef,
    this.userPlaylist = false,
    this.playlistId,
    this.icon,
  });
  @override
  Widget build(BuildContext context, ref) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final mediaQuery = MediaQuery.of(context);
    final router = GoRouter.of(context);
    final ThemeData(:colorScheme) = Theme.of(context);
    final playlist = ref.watch(audioPlayerProvider);
    final playback = ref.watch(audioPlayerProvider.notifier);
    
    // 使用新的认证提供者
    final authState = ref.watch(authenticationProvider);
    final spotifyAuth = authState[MusicPlatform.spotify];
    final youtubeAuth = authState[MusicPlatform.youtubeMusic];
    
    // 判断音轨来源
    final isYoutubeTrack = track.id.startsWith('youtube:') || track.id.contains('youtube');
    // 获取导航服务
    final navigationService = ref.watch(navigationServiceProvider);
        
    ref.watch(downloadManagerProvider);
    final downloadManager = ref.watch(downloadManagerProvider.notifier);
    final blacklist = ref.watch(blacklistProvider);
    
    // 使用现有的提供者
    final me = ref.watch(meProvider);
    final youtubeMusicState = ref.watch(youtubeMusicStateProvider);

    final favorites = useTrackToggleLike(track, ref);

    final isBlackListed = useMemoized(
      () => blacklist.asData?.value.any(
        (element) => element.elementId == track.id,
      ),
      [blacklist, track],
    );

    final removingTrack = useState<String?>(null);
    
    // 使用现有的播放列表提供者
    final favoritePlaylistsNotifier = ref.watch(favoritePlaylistsProvider.notifier);

    final isInQueue = useMemoized(() {
      if (playlist.activeTrack == null) return false;
      return downloadManager.isActive(playlist.activeTrack!);
    }, [
      playlist.activeTrack,
      downloadManager,
    ]);

    final progressNotifier = useMemoized(() {
      final spotubeTrack = downloadManager.mapToSourcedTrack(track);
      if (spotubeTrack == null) return null;
      return downloadManager.getProgressNotifier(spotubeTrack);
    });

    final isLocalTrack = track is LocalTrack;
    
    // 检查是否有权限操作
    final bool isAuthenticated;
    if (isYoutubeTrack) {
      isAuthenticated = youtubeAuth?.valueOrNull != null;
    } else {
      isAuthenticated = spotifyAuth?.valueOrNull != null;
    }
    
    final adaptivePopSheetList = AdaptivePopSheetList<TrackOptionValue>(
      onSelected: (value) async {
        switch (value) {
          case TrackOptionValue.album:
            if (track.albumId != null) {
              navigationService.navigateToAlbumById(track.albumId!);
            }
            break;
            
          case TrackOptionValue.track:
            // 使用导航服务导航到音轨页面
            navigationService.navigateToTrack(track);
            break;
            
          case TrackOptionValue.artist:
            if (track.artists?.isNotEmpty == true) {
              // 直接使用艺术家名称作为ID
              // 因为在这种情况下，track.artists 是字符串列表
              navigationService.navigateToArtist(track.artists!.first);
            }
            break;
            
          case TrackOptionValue.delete:
            if (isLocalTrack) {
              await File((track as LocalTrack).path).delete();
              ref.invalidate(localTracksProvider);
            }
            break;
          case TrackOptionValue.addToQueue:
            await playback.addTrack(track);
            if (context.mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.added_track_to_queue(track.title),
                  ),
                ),
              );
            }
            break;
          case TrackOptionValue.playNext:
            playback.addTracksAtFirst([track]);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.track_will_play_next(track.title),
                ),
              ),
            );
            break;
          case TrackOptionValue.removeFromQueue:
            playback.removeTrack(track.id);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.removed_track_from_queue(
                    track.title,
                  ),
                ),
              ),
            );
            break;
          case TrackOptionValue.favorite:
            favorites.toggleTrackLike(track);
            break;
          case TrackOptionValue.addToPlaylist:
            // 直接使用 TrackOptionsActions 中的方法，不再区分平台
            TrackOptionsActions.actionAddToPlaylist(context, track, playlistId);
            break;
          case TrackOptionValue.removeFromPlaylist:
            removingTrack.value = track.id;
            if (isYoutubeTrack) {
              // 使用 YouTube Music 播放列表操作
              final playlistActions = ref.read(youtubeMusicPlaylistActionsProvider);
              await playlistActions.removeTrackFromPlaylist(playlistId ?? "", track.id);
              
              // 刷新播放列表
              ref.invalidate(youtubeMusicPlaylistTracksProvider(playlistId ?? ""));
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.removed_track_from_queue(
                        track.title,
                      ),
                    ),
                  ),
                );
              }
            } else {
              // Spotify 从播放列表移除逻辑
              await favoritePlaylistsNotifier.removeTracks(playlistId ?? "", [track.id]);
            }
            removingTrack.value = null;
            break;
          case TrackOptionValue.blacklist:
            if (isBlackListed == null) break;
            if (isBlackListed == true) {
              await ref.read(blacklistProvider.notifier).remove(track.id);
            } else {
              await ref.read(blacklistProvider.notifier).add(
                    BlacklistTableCompanion.insert(
                      name: track.title,
                      elementId: track.id,
                      elementType: BlacklistedType.track,
                    ),
                  );
            }
            break;
          case TrackOptionValue.share:
            TrackOptionsActions.actionShare(context, track);
            break;
          case TrackOptionValue.songlink:
            final url = "https://song.link/s/${track.id}";
            await launchUrlString(url);
            break;
          case TrackOptionValue.details:
            showDialog(
              context: context,
              builder: (context) => TrackDetailsDialog(track: track),
            );
            break;
          case TrackOptionValue.download:
            await downloadManager.addToQueue(track);
            break;
          case TrackOptionValue.startRadio:
            if (isYoutubeTrack) {
              // 使用 YouTube Music 电台功能
              final service = ref.read(youtubeMusicProvider);
              final radioTracks = await service.getRadioTracks(track.id);
              
              // 添加到播放队列
              await playback.load(
                radioTracks,
                initialIndex: 0,
                autoPlay: true,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Started radio for ${track.title}",
                    ),
                  ),
                );
              }
            } else {
              // Spotify 电台逻辑
              TrackOptionsActions.actionStartRadio(context, ref, track);
            }
            break;
        }
      },
      icon: icon ?? const Icon(SpotubeIcons.moreHorizontal),
      headings: [
        TrackOptionsHeader(track: track),
      ],
      children: [
        if (isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.delete,
            leading: const Icon(SpotubeIcons.trash),
            title: Text(context.l10n.delete),
          ),
        if (mediaQuery.smAndDown && !isLocalTrack && track.albumId != null)
          PopSheetEntry(
            value: TrackOptionValue.album,
            leading: const Icon(SpotubeIcons.album),
            title: Text(context.l10n.go_to_album),
            subtitle: Text(track.albumName ?? ''),
          ),
        if (!playlist.containsTrack(track)) ...[
          PopSheetEntry(
            value: TrackOptionValue.addToQueue,
            leading: const Icon(SpotubeIcons.queueAdd),
            title: Text(context.l10n.add_to_queue),
          ),
          PopSheetEntry(
            value: TrackOptionValue.playNext,
            leading: const Icon(SpotubeIcons.lightning),
            title: Text(context.l10n.play_next),
          ),
        ] else
          PopSheetEntry(
            value: TrackOptionValue.removeFromQueue,
            enabled: playlist.activeTrack?.id != track.id,
            leading: const Icon(SpotubeIcons.queueRemove),
            title: Text(context.l10n.remove_from_queue),
          ),
        if (isAuthenticated && !isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.favorite,
            leading: favorites.isLiked
                ? const Icon(
                    SpotubeIcons.heartFilled,
                    color: Colors.pink,
                  )
                : const Icon(SpotubeIcons.heart),
            title: Text(
              favorites.isLiked
                  ? context.l10n.remove_from_favorites
                  : context.l10n.save_as_favorite,
            ),
          ),
        if (isAuthenticated && !isLocalTrack) ...[
          PopSheetEntry(
            value: TrackOptionValue.startRadio,
            leading: const Icon(SpotubeIcons.radio),
            title: Text(context.l10n.start_a_radio),
          ),
          PopSheetEntry(
            value: TrackOptionValue.addToPlaylist,
            leading: const Icon(SpotubeIcons.playlistAdd),
            title: Text(context.l10n.add_to_playlist),
          ),
        ],
        if (userPlaylist && isAuthenticated && !isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.removeFromPlaylist,
            leading: const Icon(SpotubeIcons.removeFilled),
            title: Text(context.l10n.remove_from_playlist),
          ),
        if (!isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.download,
            enabled: !isInQueue,
            leading: isInQueue
                ? HookBuilder(builder: (context) {
                    final progress = useListenable(progressNotifier!);
                    return CircularProgressIndicator(
                      value: progress.value,
                    );
                  })
                : const Icon(SpotubeIcons.download),
            title: Text(context.l10n.download_track),
          ),
        if (!isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.blacklist,
            leading: const Icon(SpotubeIcons.playlistRemove),
            iconColor: isBlackListed != true ? Colors.red[400] : null,
            textColor: isBlackListed != true ? Colors.red[400] : null,
            title: Text(
              isBlackListed == true
                  ? context.l10n.remove_from_blacklist
                  : context.l10n.add_to_blacklist,
            ),
          ),
        if (!isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.share,
            leading: const Icon(SpotubeIcons.share),
            title: Text(context.l10n.share),
          ),
        if (!isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.songlink,
            leading: Assets.logos.songlinkTransparent.image(
              width: 22,
              height: 22,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            title: Text(context.l10n.song_link),
          ),
        if (!isLocalTrack)
          PopSheetEntry(
            value: TrackOptionValue.details,
            leading: const Icon(SpotubeIcons.info),
            title: Text(context.l10n.details),
          ),
      ],
    );

    //! This is the most ANTI pattern I've ever done, but it works
    showMenuCbRef?.value = (relativeRect) {
      adaptivePopSheetList.showPopupMenu(context, relativeRect);
    };

    return ListTileTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: adaptivePopSheetList,
    );
  }
}