import 'package:spotube/models/lyrics.dart';
import 'package:spotube/services/base/base_track.dart';

abstract class BaseLyricsProvider<T extends BaseTrack> {
  final T track;
  
  const BaseLyricsProvider(this.track);
  
  Future<SubtitleSimple?> getLyrics();
}