import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/string.dart';
import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/services/navigation/navigation_service.dart';
// 导入通用 Playlist 类型
import 'package:spotube/services/base/playlist.dart';

class StatsPlaylistItem extends StatelessWidget {
  // 使用通用 Playlist 类型替代 Spotify 的 PlaylistSimple
  final Playlist playlist;
  final Widget info;
  const StatsPlaylistItem(
      {super.key, required this.playlist, required this.info});

  @override
  Widget build(BuildContext context) {
    // 获取导航服务
    final navigationService = ProviderScope.containerOf(context).read(navigationServiceProvider);

    return ListTile(
      horizontalTitleGap: 8,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: UniversalImage(
          // 直接使用 playlist.imageUrl
          path: playlist.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.collection),
          width: 40,
          height: 40,
        ),
      ),
      title: Text(playlist.name),
      subtitle: Text(
        playlist.description?.unescapeHtml() ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: info,
      onTap: () {
        // 使用导航服务，传递播放列表ID
        navigationService.navigateToPlaylistById(playlist.id);
      },
    );
  }
}
