part of '../spotify.dart';

// 定义 Spotify 歌词提供者的类型和优先级
enum SpotifyLyricsProviderType {
  spotify,
  lrcLib, 
  petitLyrics;
  
  int get priority {
    switch (this) {
      case SpotifyLyricsProviderType.spotify:
        return 100;
      case SpotifyLyricsProviderType.lrcLib:
        return 90;
      case SpotifyLyricsProviderType.petitLyrics:
        return 80;        
    }
  }
}

// 提供者顺序配置
final spotifyLyricsProvidersOrderProvider = StateProvider<List<SpotifyLyricsProviderType>>((ref) => [
  SpotifyLyricsProviderType.spotify,
  SpotifyLyricsProviderType.lrcLib,
  SpotifyLyricsProviderType.petitLyrics,
]);

// 注册为统一的歌词提供者
final spotifyLyricsProvider = AsyncNotifierProviderFamily<LyricsNotifier, SubtitleSimple, BaseTrack?>(
  () => SpotifyLyricsNotifier(),
);