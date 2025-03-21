import 'package:spotube/collections/assets.gen.dart';
import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotube/services/base/sourceable_track.dart';

import 'package:spotube/models/spotify/track.dart';

extension SourceableTrackExtension on SourceableTrack? {
  // 获取专辑封面图片URL
  String getAlbumArt() {
    if (this == null) return Assets.albumPlaceholder.path;
    
    // 根据不同平台的 track 类型获取图片
    if (this is SpotifyTrack) {
      final track = this as SpotifyTrack;
      // 从 Spotify 曲目获取缩略图
      if (track.thumbnailUrl != null) {
        return track.thumbnailUrl!;
      }
    } else if (this is YoutubeMusicTrack) {
      final track = this as YoutubeMusicTrack;
      // 从 YouTube Music 获取缩略图
      return track.thumbnailUrl;
        }
    
    return Assets.albumPlaceholder.path;
  }
}