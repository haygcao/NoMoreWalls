import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/components/links/artist_link.dart';
import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/services/navigation/navigation_service.dart';

import 'package:spotube/models/spotify/track.dart';
// 添加通用 Artist 类型
import 'package:spotube/services/base/artist.dart';

class StatsTrackItem extends StatelessWidget {
  // 这里仍然使用 Spotify 的 Track，但我们会在内部转换
  final dynamic track;
  final Widget info;
  const StatsTrackItem({
    super.key,
    required this.track,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    // 获取导航服务
    final navigationService = ProviderScope.containerOf(context).read(navigationServiceProvider);
    
    // 创建 SpotifyTrack 对象
    final sourceableTrack = SpotifyTrack.fromTrack(track);
    
    // 将 Spotify 的 Artist 转换为通用 Artist
    final artists = track.artists?.map<Artist>((artist) => Artist(
      id: artist.id ?? '',
      name: artist.name ?? '',
      uri: artist.uri ?? '',
    )).toList() ?? <Artist>[];
    
    return ListTile(
      horizontalTitleGap: 8,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: UniversalImage(
          // 使用 MediaImageUtils 处理图片
          path: _getAlbumArtUrl(track),
          width: 40,
          height: 40,
        ),
      ),
      title: Text(track.name ?? ''),
      subtitle: ArtistLink(
        artists: artists,
        mainAxisAlignment: WrapAlignment.start,
        onOverflowArtistClick: () => navigationService.navigateToTrack(sourceableTrack),
      ),
      trailing: info,
      onTap: () {
        // 使用导航服务
        navigationService.navigateToTrack(sourceableTrack);
      },
    );
  }
  
  // 提取获取专辑封面的方法
  String _getAlbumArtUrl(dynamic track) {
    if (track.album?.images == null || track.album?.images?.isEmpty == true) {
      return MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt);
    }
    
    // 将专辑图片转换为 MediaImage 列表
    final images = track.album.images.map<MediaImage>((img) => _MediaImageImpl(
      height: img.height,
      width: img.width,
      url: img.url,
    )).toList();
    
    return MediaImageUtils.getImageUrl(
      images,
      placeholder: ImagePlaceholder.albumArt,
    );
  }
}

// 创建通用的 MediaImage 实现
class _MediaImageImpl implements MediaImage {
  @override
  final int? height;
  
  @override
  final int? width;
  
  @override
  final String? url;
  
  _MediaImageImpl({
    this.height,
    this.width,
    this.url,
  });
}
