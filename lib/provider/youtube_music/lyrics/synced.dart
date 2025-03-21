part of '../youtube_music.dart';

enum YoutubeMusicLyricsProviderType {
  youtube,
  lrcLib, 
  spotify, 
  petitLyrics;

  int get priority {
    switch (this) {
      case YoutubeMusicLyricsProviderType.youtube:
        return 100;
      case YoutubeMusicLyricsProviderType.spotify:
        return 98;
      case YoutubeMusicLyricsProviderType.lrcLib:
        return 90;
      case YoutubeMusicLyricsProviderType.petitLyrics:
        return 80;         
    }
  }
}

final youtubeMusicLyricsProvidersOrderProvider = StateProvider<List<YoutubeMusicLyricsProviderType>>((ref) => [
  YoutubeMusicLyricsProviderType.youtube,
  YoutubeMusicLyricsProviderType.spotify,
  YoutubeMusicLyricsProviderType.lrcLib,
  YoutubeMusicLyricsProviderType.petitLyrics,
]);



// 注册为统一的歌词提供者
final youtubeMusicLyricsProvider = AsyncNotifierProviderFamily<LyricsNotifier, SubtitleSimple, BaseTrack?>(
  () => YoutubeMusicLyricsNotifier(),
);