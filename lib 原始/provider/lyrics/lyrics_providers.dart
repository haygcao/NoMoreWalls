import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/models/lyrics.dart';

import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/base/sourceable_track.dart';

// 统一的歌词延迟配置
final lyricsDelayProvider = StateProvider<int>((ref) => 0);

// 基础歌词 Notifier
abstract class LyricsNotifier extends FamilyAsyncNotifier<SubtitleSimple, BaseTrack?> {
  @override
  Future<SubtitleSimple> build(BaseTrack? track);
}

// 统一的歌词获取接口
final lyricsProvider = AsyncNotifierProviderFamily<LyricsNotifier, SubtitleSimple, BaseTrack?>(
  () => throw UnimplementedError('请使用具体的歌词提供者'),
);

// 统一的歌词映射接口
final lyricsMapProvider = FutureProvider.family<({bool static, Map<int, String> lyricsMap}), BaseTrack?>((ref, track) async {
  final syncedLyrics = await ref.watch(lyricsProvider(track).future);
  final isStaticLyrics = syncedLyrics.lyrics.every((l) => l.time == Duration.zero);
  final lyricsMap = syncedLyrics.lyrics
      .map((lyric) => <int, String>{lyric.time.inSeconds: lyric.text})
      .reduce((accumulator, lyricSlice) => {...accumulator, ...lyricSlice});

  return (static: isStaticLyrics, lyricsMap: lyricsMap);
});

// 歌词映射转换器
Future<({bool static, Map<int, String> lyricsMap})> convertLyricsToMap(SubtitleSimple lyrics) async {
  final isStaticLyrics = lyrics.lyrics.every((l) => l.time == Duration.zero);
  
  final lyricsMap = lyrics.lyrics
      .map((lyric) => <int, String>{lyric.time.inSeconds: lyric.text})
      .reduce((accumulator, lyricSlice) => {...accumulator, ...lyricSlice});

  return (static: isStaticLyrics, lyricsMap: lyricsMap);
}
class SourceableTrackAdapter implements BaseTrack {
  final SourceableTrack track;

  SourceableTrackAdapter(this.track);

  String get name => track.title;

  String get artist => track.artistName;

  @override
  String get id => track.id;

  @override
  String get title => track.title;

  @override
  String get artistName => track.artistName;

  @override
  String? get albumName => track.albumName;

  @override
  Duration get duration => track.duration;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artistName': artistName,
        'albumName': albumName,
        'duration': duration.inMilliseconds,
      };
}

// 修改当前播放曲目的适配器
final activeTrackProvider = Provider<BaseTrack?>((ref) {
  final playback = ref.watch(audioPlayerProvider);
  final track = playback.activeTrack;
  
  return track != null ? SourceableTrackAdapter(track) : null;
});
