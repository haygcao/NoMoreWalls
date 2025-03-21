import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/services/navigation/navigation_service.dart';
// 导入通用 Artist 类型
import 'package:spotube/services/base/artist.dart';

class StatsArtistItem extends StatelessWidget {
  // 使用通用 Artist 类型替代 Spotify 的 Artist
  final Artist artist;
  final Widget info;
  const StatsArtistItem({
    super.key,
    required this.artist,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    // 获取导航服务
    final navigationService = ProviderScope.containerOf(context).read(navigationServiceProvider);

    return ListTile(
      title: Text(artist.name),
      horizontalTitleGap: 8,
      leading: CircleAvatar(
        backgroundImage: UniversalImage.imageProvider(
          // 直接使用 artist.imageUrl
          artist.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.artist),
        ),
      ),
      trailing: info,
      onTap: () {
        // 使用导航服务
        navigationService.navigateToArtist(artist.id);
      },
    );
  }
}
