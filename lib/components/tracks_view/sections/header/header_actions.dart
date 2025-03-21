import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/modules/playlist/playlist_create_dialog.dart';
import 'package:spotube/components/heart_button/heart_button.dart';
import 'package:spotube/components/tracks_view/sections/body/use_is_user_playlist.dart';
import 'package:spotube/components/tracks_view/track_view_props.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/collection.dart';
import 'package:spotube/provider/history/history.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';

class TrackViewHeaderActions extends HookConsumerWidget {
  const TrackViewHeaderActions({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final props = InheritedTrackView.of(context);

    final playlist = ref.watch(audioPlayerProvider);
    final playlistNotifier = ref.watch(audioPlayerProvider.notifier);
    final historyNotifier = ref.watch(playbackHistoryActionsProvider);

    final isActive = playlist.collections.contains(props.collectionId);

    final isUserPlaylist = useIsUserPlaylist(ref, props.collectionId);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 获取当前平台的认证状态
    final auth = ref.watch(authenticationProvider);
    final currentPlatformAuth = auth[ref.watch(currentMusicPlatformProvider)];

    final copiedText =
        context.l10n.copied_shareurl_to_clipboard(props.shareUrl);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.l10n.share,
          icon: const Icon(SpotubeIcons.share),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: props.shareUrl),
            );

            scaffoldMessenger.showSnackBar(
              SnackBar(
                width: 300,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  copiedText,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(SpotubeIcons.queueAdd),
          tooltip: context.l10n.add_to_queue,
          onPressed: isActive || props.tracks.isEmpty
              ? null
              : () async {
                  final tracks = await props.pagination.onFetchAll();
                  await playlistNotifier.addTracks(tracks);
                  playlistNotifier.addCollection(props.collectionId);
                  
                  // 使用 Collection 类型判断
                  if (props.collection.type == CollectionType.album.name) {
                    // 修改为 AlbumBase 类型
                    historyNotifier.addAlbums([props.collection as AlbumBase]);
                  } else {
                    // 修改为 PlaylistCollection 类型
                    historyNotifier.addPlaylists([props.collection as PlaylistCollection]);
                  }
                },
        ),
        
        // 使用当前平台的认证状态，添加空检查
        if (props.onHeart != null && currentPlatformAuth?.asData?.value != null)
          HeartButton(
            isLiked: props.isLiked,
            icon: isUserPlaylist ? SpotubeIcons.trash : null,
            tooltip: props.isLiked
                ? context.l10n.remove_from_favorites
                : context.l10n.save_as_favorite,
            onPressed: () async {
              final shouldPop = await props.onHeart?.call();
              if (isUserPlaylist && shouldPop == true && context.mounted) {
                context.pop();
              }
            },
          ),
        if (isUserPlaylist)
          IconButton(
            icon: const Icon(SpotubeIcons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return PlaylistCreateDialog(
                    playlistId: props.collectionId,
                    trackIds: props.tracks.map((e) => e.id!).toList(),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
