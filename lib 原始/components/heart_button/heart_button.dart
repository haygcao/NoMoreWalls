import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/components/heart_button/use_track_toggle_like.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/music_platform.dart';
// 移除 Spotify 依赖
// import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/services/base/sourceable_track.dart';


class HeartButton extends HookConsumerWidget {
  final bool isLiked;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? color;
  final String? tooltip;
  const HeartButton({
    required this.isLiked,
    required this.onPressed,
    this.color,
    this.tooltip,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 使用新的认证提供者
    final authState = ref.watch(authenticationProvider);
    final spotifyAuth = authState[MusicPlatform.spotify];
    final youtubeAuth = authState[MusicPlatform.youtubeMusic];

    // 如果没有任何平台登录，则不显示
    if ((spotifyAuth?.valueOrNull == null) && (youtubeAuth?.valueOrNull == null)) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: tooltip,
      icon: AnimatedSwitcher(
        switchInCurve: Curves.fastOutSlowIn,
        switchOutCurve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Icon(
          icon ??
              (isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded),
          key: ValueKey(isLiked),
          color: color ?? (isLiked ? color ?? Colors.red : null),
        ),
      ),
      onPressed: onPressed,
    );
  }
}

class TrackHeartButton extends HookConsumerWidget {
  final SourceableTrack track;
  const TrackHeartButton({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 判断音轨来源
    final isYoutubeTrack =
        track.id.startsWith('youtube:') || track.id.contains('youtube');

    // 使用通用的收藏切换钩子
    final (:isLiked, :toggleTrackLike) = useTrackToggleLike(track, ref);

    // 获取认证状态
    final authState = ref.watch(authenticationProvider);
    final spotifyAuth = authState[MusicPlatform.spotify];
    final youtubeAuth = authState[MusicPlatform.youtubeMusic];

    // 根据音轨类型和认证状态决定是否显示加载指示器
    final bool isLoading;
    if (isYoutubeTrack) {
      isLoading = youtubeAuth?.isLoading ?? false;
    } else {
      isLoading = spotifyAuth?.isLoading ?? false;
    }

    if (isLoading) {
      return const CircularProgressIndicator();
    }

    // 检查是否有权限操作
    final bool canInteract;
    if (isYoutubeTrack) {
      canInteract = youtubeAuth?.valueOrNull != null;
    } else {
      canInteract = spotifyAuth?.valueOrNull != null;
    }

    return HeartButton(
      tooltip: isLiked
          ? context.l10n.remove_from_favorites
          : context.l10n.save_as_favorite,
      isLiked: isLiked,
      onPressed: canInteract
          ? () {
              toggleTrackLike(track);
            }
          : null,
    );
  }
}
