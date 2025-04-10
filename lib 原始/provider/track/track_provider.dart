import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/spotify/sourceable_track_adapter.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';

final unifiedTrackProvider = FutureProvider.autoDispose.family<SourceableTrack, String>(
  (ref, trackId) async {
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      try {
        final youtubeMusic = ref.read(youtubeMusicProvider);
        return await youtubeMusic.getTrack(trackId);
      } catch (e) {
        // 如果 YouTube Music 获取失败，尝试使用 Spotify
        final spotifyTrack = await ref.read(trackProvider(trackId).future);
        return SpotifySourceableTrackAdapter(spotifyTrack);
      }
    } else {
      // 默认使用 Spotify
      final spotifyTrack = await ref.read(trackProvider(trackId).future);
      return SpotifySourceableTrackAdapter(spotifyTrack);
    }
  },
);