import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/hover_builder.dart';
import 'package:spotube/components/image/universal_image.dart';

import 'package:spotube/components/links/link_text.dart';
import 'package:spotube/components/track_tile/track_options.dart';
// 移除 Spotify 特定扩展
// import 'package:spotube/extensions/spotify/artist_simple.dart';
// import 'package:spotube/extensions/spotify/image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/duration.dart';
import 'package:spotube/models/local_track.dart';
// 移除页面依赖
// import 'package:spotube/pages/track/track.dart';
import 'package:spotube/provider/audio_player/querying_track_info.dart';
import 'package:spotube/provider/audio_player/state.dart';
import 'package:spotube/provider/blacklist_provider.dart';
import 'package:spotube/utils/platform.dart';

// 添加通用接口
import 'package:spotube/services/base/sourceable_track.dart';
// 添加图片工具
import 'package:spotube/utils/type/image_type.dart';

class TrackTile extends HookConsumerWidget {
  /// [index] will not be shown if null
  final int? index;
  // 修改为 SourceableTrack 类型
  final SourceableTrack track;
  final bool selected;
  final ValueChanged<bool?>? onChanged;
  final Future<void> Function()? onTap;
  final VoidCallback? onLongPress;
  final bool userPlaylist;
  final String? playlistId;
  final AudioPlayerState playlist;

  final List<Widget>? leadingActions;

  const TrackTile({
    super.key,
    this.index,
    required this.track,
    this.selected = false,
    required this.playlist,
    this.onTap,
    this.onLongPress,
    this.onChanged,
    this.userPlaylist = false,
    this.playlistId,
    this.leadingActions,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);

    final blacklist = ref.watch(blacklistProvider);
    final blacklistNotifier = ref.watch(blacklistProvider.notifier);

    final isBlackListed = useMemoized(
      () => blacklistNotifier.contains(track),
      [blacklist, track],
    );

    final showOptionCbRef = useRef<ValueChanged<RelativeRect>?>(null);

    final isLoading = useState(false);

    final isPlaying = playlist.activeTrack?.id == track.id;

    final isSelected = isPlaying || isLoading.value;

    return LayoutBuilder(builder: (context, constrains) {
      return Listener(
        onPointerDown: (event) {
          if (event.buttons != kSecondaryMouseButton) return;
          showOptionCbRef.value?.call(
            RelativeRect.fromLTRB(
              event.position.dx,
              event.position.dy,
              constrains.maxWidth - event.position.dx,
              constrains.maxHeight - event.position.dy,
            ),
          );
        },
        child: HoverBuilder(
          permanentState: isSelected || constrains.smAndDown ? true : null,
          builder: (context, isHovering) => ListTile(
            selected: isSelected,
            onTap: () async {
              try {
                isLoading.value = true;
                await onTap?.call();
              } finally {
                if (context.mounted) {
                  isLoading.value = false;
                }
              }
            },
            onLongPress: onLongPress,
            enabled: !isBlackListed,
            contentPadding: EdgeInsets.zero,
            tileColor: isBlackListed ? theme.colorScheme.errorContainer : null,
            horizontalTitleGap: 12,
            leadingAndTrailingTextStyle: theme.textTheme.bodyMedium,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...?leadingActions,
                if (index != null && onChanged == null && constrains.mdAndUp)
                  SizedBox(
                    width: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${(index ?? 0) + 1}',
                        maxLines: 1,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (constrains.smAndDown)
                  const SizedBox(width: 16),
                if (onChanged != null)
                  Checkbox(
                    value: selected,
                    onChanged: onChanged,
                  ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: UniversalImage(
                          // 使用通用的缩略图URL
                          path: track.thumbnailUrl ?? 
                                MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isHovering
                              ? Colors.black.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: IconTheme(
                          data: theme.iconTheme
                              .copyWith(size: 26, color: Colors.white),
                          child: Skeleton.ignore(
                            child: Consumer(
                              builder: (context, ref, _) {
                                final isFetchingActiveTrack =
                                    ref.watch(queryingTrackInfoProvider);
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: (isPlaying && isFetchingActiveTrack) ||
                                          isLoading.value
                                      ? const SizedBox(
                                          width: 26,
                                          height: 26,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : isPlaying
                                          ? Icon(
                                              SpotubeIcons.pause,
                                              color: theme.colorScheme.primary,
                                            )
                                          : !isHovering
                                              ? const SizedBox.shrink()
                                              : const Icon(SpotubeIcons.play),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: switch (track) {
                    LocalTrack() => Text(
                        (track as LocalTrack).title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    _ => LinkText(
                        track.title,
                        "/track/${track.id}",
                        push: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  },
                ),
                if (constrains.mdAndUp) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: switch (track) {
                      LocalTrack() => Text(
                          (track as LocalTrack).albumName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      _ => Align(
                          alignment: Alignment.centerLeft,
                          child: LinkText(
                            track.albumName ?? '',
                            "/album/${track.albumId}",
                            push: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                    },
                  ),
                ],
              ],
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: track is LocalTrack
                  ? Text(
                      (track as LocalTrack).artistName,
                    )
                  : Text(track.artistName),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Text(
                  track.duration.toHumanReadableString(padZero: false),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TrackOptions(
                  track: track,
                  playlistId: playlistId,
                  userPlaylist: userPlaylist,
                  showMenuCbRef: showOptionCbRef,
                ),
                if (kIsDesktop) const Gap(10),
              ],
            ),
          ),
        ),
      );
    });
  }
}
