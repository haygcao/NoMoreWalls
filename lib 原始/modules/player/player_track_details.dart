import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 特定导入
import 'package:spotube/collections/assets.gen.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
// 使用通用图片类型
import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/navigation/navigation_service.dart';

class PlayerTrackDetails extends HookConsumerWidget {
  final Color? color;
  final SourceableTrack? track;
  const PlayerTrackDetails({super.key, this.color, this.track});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final playback = ref.watch(audioPlayerProvider);
    final navigationService = ref.watch(navigationServiceProvider);

    return Row(
      children: [
        if (playback.activeTrack != null)
          Container(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(
              maxWidth: 80,
              maxHeight: 80,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: UniversalImage(
                path: playback.activeTrack?.thumbnailUrl ?? 
                    MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
                placeholder: Assets.albumPlaceholder.path,
              ),
            ),
          ),
        if (mediaQuery.mdAndDown)
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: playback.activeTrack != null
                      ? () => navigationService.navigateToTrack(playback.activeTrack!)
                      : null,
                  child: Text(
                    playback.activeTrack?.title ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: color,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  playback.activeTrack?.artistName ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(color: color),
                )
              ],
            ),
          ),
        if (mediaQuery.lgAndUp)
          Flexible(
            flex: 1,
            child: Column(
              children: [
                GestureDetector(
                  onTap: playback.activeTrack != null
                      ? () => navigationService.navigateToTrack(playback.activeTrack!)
                      : null,
                  child: Text(
                    playback.activeTrack?.title ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: color,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: playback.activeTrack?.artistId != null
                      ? () => navigationService.navigateToArtist(playback.activeTrack!.artistId!)
                      : null,
                  child: Text(
                    playback.activeTrack?.artistName ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
