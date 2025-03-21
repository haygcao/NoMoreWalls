import 'package:dio/dio.dart';
import 'package:lrc/lrc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/services/dio/dio.dart';
import 'package:spotube/services/logger/logger.dart';
import '../base_lyrics_provider.dart';
import '../../../services/base/base_track.dart';

class LRCLibLyricsProvider<T extends BaseTrack> extends BaseLyricsProvider<T> {
  const LRCLibLyricsProvider(super.track);
  
  @override
  Future<SubtitleSimple?> getLyrics() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final res = await globalDio.getUri(
        Uri(
          scheme: "https",
          host: "lrclib.net",
          path: "/api/get",
          queryParameters: {
            "artist_name": track.artistName,
            "track_name": track.title,
            "album_name": track.albumName,
            "duration": track.duration?.inSeconds.toString(),
          },
        ),
        options: Options(
          headers: {
            "User-Agent": "Spotube v${packageInfo.version}"
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
          provider: "LRCLib",
        );
      }

      final json = res.data as Map<String, dynamic>;
      final syncedLyricsRaw = json["syncedLyrics"] as String?;
      
      if (syncedLyricsRaw?.isNotEmpty == true) {
        final syncedLyrics = Lrc.parse(syncedLyricsRaw!)
            .lyrics
            .map(LyricSlice.fromLrcLine)
            .toList();

        return SubtitleSimple(
          lyrics: syncedLyrics,
          name: track.title,
          uri: res.realUri,
          rating: 90,
          provider: "LRCLib",
        );
      }

      final plainLyrics = (json["plainLyrics"] as String?)?.split("\n")
          .map((line) => LyricSlice(text: line, time: Duration.zero))
          .toList();

      if (plainLyrics != null) {
        return SubtitleSimple(
          lyrics: plainLyrics,
          name: track.title,
          uri: res.realUri,
          rating: 50,
          provider: "LRCLib",
        );
      }

      return null;
    } catch (e) {
      AppLogger.reportError(e);
      return null;
    }
  }
}