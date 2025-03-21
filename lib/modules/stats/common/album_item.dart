import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
// 移除未使用的导入
// import 'package:spotube/modules/album/album_card.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/components/links/artist_link.dart';
import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/services/navigation/navigation_service.dart';
// 导入通用 Artist 和 Album 类型
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/services/base/album.dart';

class StatsAlbumItem extends StatelessWidget {
  // 使用通用 Album 类型替代 Spotify 的 AlbumSimple
  final Album album;
  final Widget info;
  const StatsAlbumItem({super.key, required this.album, required this.info});

  @override
  Widget build(BuildContext context) {
    // 获取导航服务
    final navigationService = ProviderScope.containerOf(context).read(navigationServiceProvider);

    return ListTile(
      horizontalTitleGap: 8,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: UniversalImage(
          path: album.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
          width: 40,
          height: 40,
        ),
      ),
      title: Text(album.name),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${album.albumType?.toLowerCase() ?? 'album'} • "),
          Flexible(
            child: ArtistLink(
              // 直接使用通用 Artist 列表
              artists: _getArtistsFromNames(album.artists),
              mainAxisAlignment: WrapAlignment.start,
              onOverflowArtistClick: () => navigationService.navigateToAlbumById(album.id),
            ),
          ),
        ],
      ),
      trailing: info,
      onTap: () {
        // 使用导航服务，传递专辑ID
        navigationService.navigateToAlbumById(album.id);
      },
    );
  }
  
  // 从艺术家名称列表创建 Artist 对象列表
  List<Artist> _getArtistsFromNames(List<String>? artistNames) {
    if (artistNames == null) return [];
    
    return artistNames.map((name) => Artist(
      id: '', // 这里可能需要从其他地方获取ID
      name: name,
      uri: '',
    )).toList();
  }
}
