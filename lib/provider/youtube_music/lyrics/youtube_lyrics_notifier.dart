part of '../youtube_music.dart';


class YoutubeMusicLyricsNotifier extends LyricsNotifier {
  @override
  Future<SubtitleSimple> build(BaseTrack? track) async {
    if (track == null) {
      throw "No track currently playing";
    }

    try {
      final providersOrder = ref.watch(youtubeMusicLyricsProvidersOrderProvider);
      final spotify = ref.read(spotifyProvider);
      final credentials = await spotify.getCredentials();
      
      final providersMap = <YoutubeMusicLyricsProviderType, BaseLyricsProvider>{};
      
      if (credentials.accessToken != null) {
        providersMap[YoutubeMusicLyricsProviderType.spotify] = 
            SpotifyLyricsProvider(track, credentials.accessToken!);
      }
      
      providersMap[YoutubeMusicLyricsProviderType.youtube] = YoutubeMusicLyricsProvider(track);
      providersMap[YoutubeMusicLyricsProviderType.lrcLib] = LRCLibLyricsProvider(track);
      providersMap[YoutubeMusicLyricsProviderType.petitLyrics] = PetitLyricsProvider(track);

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
        name: track.title,
        uri: Uri(),
        rating: 0,
        provider: "Error",
      );
    }
  }
}