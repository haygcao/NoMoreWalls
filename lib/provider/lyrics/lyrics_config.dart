import 'package:hooks_riverpod/hooks_riverpod.dart';

enum LyricsProviderType {
  spotify,
  youtubeMusic,
  lrcLib,
  petitLyrics;

  int get priority {
    switch (this) {
      case LyricsProviderType.spotify:
        return 100;
      case LyricsProviderType.youtubeMusic:
        return 95;
      case LyricsProviderType.lrcLib:
        return 90;
      case LyricsProviderType.petitLyrics:
        return 60;
    }
  }
}

final lyricsProvidersOrderProvider = StateProvider<List<LyricsProviderType>>((ref) => [
  LyricsProviderType.spotify,
  LyricsProviderType.youtubeMusic,
  LyricsProviderType.lrcLib,
  LyricsProviderType.petitLyrics,
]);