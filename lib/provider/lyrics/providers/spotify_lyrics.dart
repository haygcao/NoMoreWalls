import 'package:dio/dio.dart';
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/services/dio/dio.dart';
import 'package:spotube/services/logger/logger.dart';
import '../base_lyrics_provider.dart';
import '../../../services/base/base_track.dart';

class SpotifyLyricsProvider<T extends BaseTrack> extends BaseLyricsProvider<T> {
  final String accessToken;
  
  const SpotifyLyricsProvider(super.track, this.accessToken);
  
  @override
  Future<SubtitleSimple?> getLyrics() async {
    try {
      final res = await globalDio.getUri(
        Uri.parse(
          "https://spclient.wg.spotify.com/color-lyrics/v2/track/${track.id}?format=json&market=from_token",
        ),
        options: Options(
          headers: {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36",
            "App-platform": "WebPlayer",
            "authorization": "Bearer $accessToken"
          },
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        ),
      );

      if (res.statusCode != 200) {
        return SubtitleSimple(
          lyrics: [],
          name: track.title,
          uri: res.realUri,
          rating: 0,
          provider: "Spotify",
        );
      }

      final linesRaw = Map.castFrom<dynamic, dynamic, String, dynamic>(res.data)["lyrics"]?["lines"] as List?;
      
      final lines = linesRaw?.map((line) {
        return LyricSlice(
          time: Duration(milliseconds: int.parse(line["startTimeMs"])),
          text: line["words"] as String,
        );
      }).toList() ?? [];

      return SubtitleSimple(
        lyrics: lines,
        name: track.title,
        uri: res.realUri,
        rating: lines.isEmpty ? 0 : 100,
        provider: "Spotify",
      );
    } catch (e) {
      AppLogger.reportError(e);
      return null;
    }
  }
}