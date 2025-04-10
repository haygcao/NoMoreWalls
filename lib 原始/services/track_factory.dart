import 'package:spotube/models/local_track.dart';
import 'package:spotube/models/spotify/track.dart';
import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotube/services/base/sourceable_track.dart';

class TrackFactory {
  // 从JSON创建音轨
  static SourceableTrack createFromJson(Map<String, dynamic> json) {
    // 添加一个类型字段，用于明确指定音轨类型
    final type = json['track_type'] as String?;
    
    if (type != null) {
      // 根据明确指定的类型创建
      switch (type) {
        case 'local':
          return LocalTrack.fromJson(json);
        case 'spotify':
          // 对于Spotify，需要先转换为spotify.Track
          final spotifyTrack = spotify.Track.fromJson(json);
          return SpotifyTrack.fromTrack(spotifyTrack);
        case 'youtube_music':
          return YoutubeMusicTrack.fromJson(json);
        default:
          break;
      }
    }
    
    // 如果没有明确指定类型，尝试根据字段特征判断
    if (json.containsKey('path')) {
      // 本地音轨特有字段
      return LocalTrack.fromJson(json);
    } else if (json.containsKey('channelId') && json.containsKey('publishedAt')) {
      // YouTube音轨特有字段
      return YoutubeMusicTrack.fromJson(json);
    } else if (json.containsKey('id') && (json.containsKey('name') || json.containsKey('title'))) {
      // Spotify音轨
      try {
        final spotifyTrack = spotify.Track.fromJson(json);
        return SpotifyTrack.fromTrack(spotifyTrack);
      } catch (e) {
        // 如果转换失败，可能是JSON格式不匹配
        // 尝试其他方式
      }
    }
    
    // 如果无法识别类型，抛出异常
    throw Exception('无法识别的音轨类型: $json');
  }
}