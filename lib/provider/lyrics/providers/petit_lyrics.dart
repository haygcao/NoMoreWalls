import 'package:dio/dio.dart';
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/services/dio/dio.dart';
import 'package:spotube/services/logger/logger.dart';
import '../base_lyrics_provider.dart';
import '../../../services/base/base_track.dart';

class PetitLyricsProvider<T extends BaseTrack> extends BaseLyricsProvider<T> {
  const PetitLyricsProvider(super.track);
  
  String _parsePetitLyricsHtml(String html) {
    const resultStart = "<a href=\"/lyrics/";
    const resultEnd = "</a>";

    final startIndex = html.indexOf(resultStart);
    if (startIndex == -1) return '';

    final endIndex = html.indexOf(resultEnd, startIndex);
    if (endIndex == -1) return '';

    return html.substring(startIndex + resultStart.length, endIndex);
  }
  
  @override
  Future<SubtitleSimple?> getLyrics() async {
    try {
      final res = await globalDio.getUri(
        Uri.parse("https://petitlyrics.com/search_lyrics").replace(
          queryParameters: {
            "title": track.title,
            "artist": track.artistName,
          },
        ),
        options: Options(
          headers: {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0"
          },
          validateStatus: (status) => true,
        ),
      );

      if (res.statusCode != 200) {
        return SubtitleSimple(
          lyrics: [],
          name: track.title,
          uri: res.realUri,
          rating: 0,
          provider: "PetitLyrics",
        );
      }

      final html = res.data as String;
      final lyrics = _parsePetitLyricsHtml(html);
      
      if (lyrics.isEmpty) {
        return null;
      }

      final lyricLines = lyrics.split('\n')
          .map((line) => LyricSlice(text: line, time: Duration.zero))
          .toList();

      return SubtitleSimple(
        lyrics: lyricLines,
        name: track.title,
        uri: res.realUri,
        rating: 60,
        provider: "PetitLyrics",
      );
    } catch (e) {
      AppLogger.reportError(e);
      return null;
    }
  }
}