import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/provider/history/top.dart';
// import 'package:spotube/provider/spotify/spotify.dart';

import 'package:spotube/services/base/sourceable_track.dart';

typedef PlaybackHistoryTrack = ({int count, SourceableTrack track});
typedef PlaybackHistoryArtist = ({int count, Map<String, dynamic> artist});

// 修改状态类定义
class HistoryTopTracksState {
  final List<PlaybackHistoryTrack> items;
  final int offset;
  final int limit;
  final bool hasMore;

  HistoryTopTracksState({
    required this.items,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  List<PlaybackHistoryArtist> get artists {
    final allArtists = <Map<String, dynamic>>[];
    
    for (final item in items) {
      final data = (item.track.toJson()['artists'] as List?)?.cast<Map<String, dynamic>>();
      if (data != null) {
        allArtists.addAll(data);
      }
    }
    
    return getArtistsWithCount(allArtists);
  }

  List<PlaybackHistoryArtist> getArtistsWithCount(List<Map<String, dynamic>> artists) {
    return groupBy(artists, (artist) => artist['id'] as String)
        .entries
        .map((entry) {
          return (count: entry.value.length, artist: entry.value.first);
        })
        .sorted((a, b) => b.count.compareTo(a.count))
        .toList();
  }

  HistoryTopTracksState copyWith({
    List<PlaybackHistoryTrack>? items,
    int? offset,
    int? limit,
    bool? hasMore,
  }) {
    return HistoryTopTracksState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HistoryTopTracksNotifier extends FamilyAsyncNotifier<HistoryTopTracksState, HistoryDuration> {
  @override
  Future<HistoryTopTracksState> build(HistoryDuration arg) async {
    final (items: tracks, hasMore: hasMore, nextOffset: nextOffset) = 
        await fetch(arg, 0, 20);

    final subscription = createTracksQuery(arg).watch().listen((event) {
      if (!state.hasValue) return;
      state = AsyncValue.data(state.value!.copyWith(
        items: getTracksWithCount(event),
        hasMore: false,
      ));
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return HistoryTopTracksState(
      items: tracks,
      offset: nextOffset,
      limit: 20,
      hasMore: hasMore,
    );
  }

  SimpleSelectStatement<$HistoryTableTable, HistoryTableData>
      createTracksQuery(HistoryDuration duration) {
    final database = ref.read(databaseProvider);

    final durationStr = switch (duration) {
      HistoryDuration.allTime => '0',
      HistoryDuration.days7 => "strftime('%s', 'now', 'weekday 0', '-7 days')",
      HistoryDuration.days30 => "strftime('%s', 'now', 'start of month')",
      HistoryDuration.months6 =>
        "strftime('%s', date('now', '-5 months', 'start of month'))",
      HistoryDuration.year => "strftime('%s', date('now', 'start of year'))",
      HistoryDuration.years2 =>
        "strftime('%s', date('now', '-1 years', 'start of year'))",
    };

    return database.select(database.historyTable)
      ..where(
        (tbl) =>
            tbl.type.equalsValue(HistoryEntryType.track) &
            tbl.createdAt.isBiggerOrEqualValue(
              DateTime.fromMillisecondsSinceEpoch(int.parse(durationStr) * 1000),
            ),
      );
  }

  Future<({
    List<PlaybackHistoryTrack> items,
    bool hasMore,
    int nextOffset,
  })> fetch(HistoryDuration duration, int offset, int limit) async {
    final tracksQuery = createTracksQuery(duration)..limit(limit, offset: offset);
    final items = getTracksWithCount(await tracksQuery.get());

    return (
      items: items,
      hasMore: items.length == limit,
      nextOffset: offset + limit,
    );
  }

  // Add fetchMore method
  Future<void> fetchMore() async {
    if (!state.hasValue || state.value!.hasMore == false) return;
    
    state = const AsyncValue.loading();
    
    final currentState = state.value!;
    final (items: tracks, hasMore: hasMore, nextOffset: nextOffset) = 
        await fetch(arg, currentState.offset, currentState.limit);
    
    state = AsyncValue.data(
      currentState.copyWith(
        items: [...currentState.items, ...tracks],
        offset: nextOffset,
        hasMore: hasMore,
      ),
    );
  }

  List<PlaybackHistoryTrack> getTracksWithCount(List<HistoryTableData> tracks) {
    return groupBy(tracks, (track) => track.itemId)
        .entries
        .map((entry) {
          final data = entry.value.first.data;
          
          // 创建一个匿名类实现 SourceableTrack 接口
          final track = _TrackFromJson(data);
          
          return (
            count: entry.value.length,
            track: track,
          );
        })
        .sorted((a, b) => b.count.compareTo(a.count))
        .toList();
  }
}

// 创建一个简单的 SourceableTrack 实现类
// 修改 _TrackFromJson 类，实现所有必需的方法
class _TrackFromJson implements SourceableTrack {
  final Map<String, dynamic> _json;
  
  _TrackFromJson(this._json);
  
  @override
  String get id => _json['id'] as String;
  
  @override
  String get title => _json['name'] as String;
  
  @override
  String get artistName {
    final artists = _json['artists'] as List?;
    return artists?.isNotEmpty == true 
        ? (artists!.first as Map<String, dynamic>)['name'] as String 
        : '';
  }
  
  @override
  String? get albumName => _json['album'] != null 
      ? (_json['album'] as Map<String, dynamic>)['name'] as String? 
      : null;
  
  @override
  Duration get duration => Duration(milliseconds: _json['duration_ms'] as int? ?? 0);
  
  @override
  String? get thumbnailUrl => _json['album'] != null 
      ? (_json['album'] as Map<String, dynamic>)['images'] != null 
          ? ((_json['album'] as Map<String, dynamic>)['images'] as List).isNotEmpty 
              ? (((_json['album'] as Map<String, dynamic>)['images'] as List).first as Map<String, dynamic>)['url'] as String? 
              : null 
          : null 
      : null;
  
  @override
  String? get artistId => _json['artists'] != null && (_json['artists'] as List).isNotEmpty 
      ? ((_json['artists'] as List).first as Map<String, dynamic>)['id'] as String? 
      : null;
  
  @override
  String? get albumId => _json['album'] != null 
      ? (_json['album'] as Map<String, dynamic>)['id'] as String? 
      : null;
  
  // Add the missing releaseDate implementation
  @override
  DateTime? get releaseDate {
    if (_json['album'] != null && (_json['album'] as Map<String, dynamic>)['release_date'] != null) {
      final releaseDate = (_json['album'] as Map<String, dynamic>)['release_date'] as String?;
      return releaseDate != null ? DateTime.tryParse(releaseDate) : null;
    }
    return null;
  }
  
  @override
  Map<String, dynamic> toJson() => _json;

  @override
  String getSearchTerm() {
    return "$title - $artistName";
  }

  @override
  String getDisplayName() {
    return "$title - $artistName";
  }

  @override
  Map<String, dynamic> toMediaItem() {
    return {
      'id': id,
      'title': title,
      'artist': artistName,
      'album': albumName,
      'duration': duration.inMilliseconds,
      'artUri': thumbnailUrl,
    };
  }

  @override
  String getDescription() {
    return "$title by $artistName${albumName != null ? " from $albumName" : ""}";
  }
}

final historyTopTracksProvider = AsyncNotifierProviderFamily<
    HistoryTopTracksNotifier, HistoryTopTracksState, HistoryDuration>(
  () => HistoryTopTracksNotifier(),
);
