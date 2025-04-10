import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/playlist/favorite_playlist_provider.dart';

bool useIsUserPlaylist(WidgetRef ref, String playlistId) {
  // 使用统一的播放列表提供者
  final userPlaylistsQuery = ref.watch(unifiedFavoritePlaylistsProvider);
  // 获取当前平台的认证状态
  final currentPlatform = ref.watch(currentMusicPlatformProvider);
  final auth = ref.watch(authenticationProvider);
  final currentAuth = auth[currentPlatform];

  return useMemoized(
    () {
      // 检查播放列表是否属于当前用户
      final authState = currentAuth?.asData?.value;
      // 从 credentials 中获取用户ID
      final userId = authState?.credentials['id'] as String?;
      
      return userPlaylistsQuery.asData?.value.items.any((e) =>
          e.id == playlistId &&
          userId != null &&
          e.owner == userId) ??
      false;
    },
    [userPlaylistsQuery.asData?.value, playlistId, currentAuth?.asData?.value],
  );
}
