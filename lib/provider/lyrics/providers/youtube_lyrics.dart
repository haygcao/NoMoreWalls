
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/services/dio/dio.dart';
import 'package:spotube/services/logger/logger.dart';
import '../base_lyrics_provider.dart';
import '../../../services/base/base_track.dart';

class YoutubeMusicLyricsProvider<T extends BaseTrack> extends BaseLyricsProvider<T> {
  const YoutubeMusicLyricsProvider(super.track);
  
  @override
  Future<SubtitleSimple?> getLyrics() async {
    try {
      final response = await globalDio.post(
        'https://music.youtube.com/youtubei/v1/browse',
        data: {
          'context': {'client': {'clientName': 'WEB_REMIX'}},
          'browseId': 'MPLAR${track.id}',
        },
      );

      if (response.statusCode != 200) {
        return SubtitleSimple(
          lyrics: [],
          name: track.title,
          uri: response.realUri,
          rating: 0,
          provider: "YouTube Music",
        );
      }

      final data = response.data;
      final lyrics = data['lyrics']?['lyrics']?['runs'] as List?;
      
      if (lyrics == null || lyrics.isEmpty) {
        return null;
      }

      final List<LyricSlice> lyricSlices = [];
      Duration currentTime = Duration.zero;
      
      for (final line in lyrics) {
        if (line['startTimeMs'] != null) {
          currentTime = Duration(milliseconds: line['startTimeMs']);
        }
        
        lyricSlices.add(LyricSlice(
          time: currentTime,
          text: line['text'] as String,
        ));
      }

      return SubtitleSimple(
        lyrics: lyricSlices,
        name: track.title,
        uri: response.realUri,
        rating: 95,
        provider: "YouTube Music",
      );
    } catch (e) {
      AppLogger.reportError(e);
      return null;
    }
  }
}