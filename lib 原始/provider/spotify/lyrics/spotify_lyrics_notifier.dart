part of '../spotify.dart';

class SpotifyLyricsNotifier extends LyricsNotifier {
  @override
  Future<SubtitleSimple> build(BaseTrack? track) async {
    if (track == null) {
      throw "No track currently playing";
    }

    try {
      final spotify = ref.read(spotifyProvider);
      final providersOrder = ref.watch(spotifyLyricsProvidersOrderProvider);
      final credentials = await spotify.getCredentials();

      // 构建提供者映射
      final providersMap = <SpotifyLyricsProviderType, BaseLyricsProvider>{};
      
      if (credentials.accessToken != null) {
        providersMap[SpotifyLyricsProviderType.spotify] = 
            SpotifyLyricsProvider(track, credentials.accessToken!);
      }
      providersMap[SpotifyLyricsProviderType.lrcLib] = 
          LRCLibLyricsProvider(track);

      // 按照配置的顺序尝试获取歌词
      for (final providerType in providersOrder) {
        final provider = providersMap[providerType];
        if (provider != null) {
          final lyrics = await provider.getLyrics();
          if (lyrics != null && lyrics.lyrics.isNotEmpty) {
            return lyrics;
          }
        }
      }

      throw Exception("No lyrics found");
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return SubtitleSimple(
        lyrics: [],
        name: track.title, // 使用 BaseTrack 的 title 属性
        uri: Uri(),
        rating: 0,
        provider: "Error",
      );
    }
  }
}