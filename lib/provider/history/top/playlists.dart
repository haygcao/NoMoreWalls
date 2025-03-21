import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/provider/history/top.dart';

import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/playlist.dart';

typedef PlaybackHistoryPlaylist = ({int count, PlaylistBase playlist});

// 添加 PaginatedState 基类
class PaginatedState {
  final List<dynamic> items;
  final int offset;
  final int limit;
  final bool hasMore;

  PaginatedState({
    required this.items,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });
}

// 修改继承为实现
class HistoryTopPlaylistsState implements PaginatedState {
  @override
  final List<PlaybackHistoryPlaylist> items;
  @override
  final int offset;
  @override
  final int limit;
  @override
  final bool hasMore;

  HistoryTopPlaylistsState({
    required this.items,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  HistoryTopPlaylistsState copyWith({
    List<PlaybackHistoryPlaylist>? items,
    int? offset,
    int? limit,
    bool? hasMore,
  }) {
    return HistoryTopPlaylistsState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// 修改 Notifier 类
class HistoryTopPlaylistsNotifier extends FamilyAsyncNotifier<HistoryTopPlaylistsState, HistoryDuration> {
  @override
  Future<HistoryTopPlaylistsState> build(HistoryDuration arg) async {
    final (items: playlists, hasMore: hasMore, nextOffset: nextOffset) = 
        await fetch(arg, 0, 20);

    final subscription = createPlaylistsQuery(arg).watch().listen((event) {
      if (!state.hasValue) return;
      state = AsyncValue.data(state.value!.copyWith(
        items: getPlaylistsWithCount(event),
        hasMore: false,
      ));
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return HistoryTopPlaylistsState(
      items: playlists,
      offset: nextOffset,
      limit: 20,
      hasMore: hasMore,
    );
  }
  // Move fetch method here
  Future<({
    List<PlaybackHistoryPlaylist> items,
    bool hasMore,
    int nextOffset,
  })> fetch(HistoryDuration duration, int offset, int limit) async {
    final playlistsQuery = createPlaylistsQuery(duration)..limit(limit, offset: offset);
    final items = getPlaylistsWithCount(await playlistsQuery.get());
  
    return (
      items: items,
      hasMore: items.length == limit,
      nextOffset: offset + limit,
    );
  }
  SimpleSelectStatement<$HistoryTableTable, HistoryTableData>
      createPlaylistsQuery(HistoryDuration duration) {
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
            tbl.type.equalsValue(HistoryEntryType.playlist) &
            tbl.createdAt.isBiggerOrEqualValue(
              DateTime.fromMillisecondsSinceEpoch(int.parse(durationStr) * 1000),
            ),
      );
  }
  List<PlaybackHistoryPlaylist> getPlaylistsWithCount(
      List<HistoryTableData> playlists,
    ) {
      return groupBy(playlists, (playlist) => playlist.itemId)
          .entries
          .map((entry) {
            final data = entry.value.first.data;
            final playlist = Playlist(
              id: data['id'] as String,
              name: data['name'] as String,
              uri: data['uri'] as String,
              description: data['description'] as String?,
              imageUrl: data['imageUrl'] as String?,
              owner: data['owner'] as String?,
              isPublic: data['isPublic'] as bool? ?? true,
              collaborative: data['collaborative'] as bool? ?? false,
              totalTracks: data['totalTracks'] as int? ?? 0,
              platformMetadata: data['platformMetadata'] as Map<String, dynamic>?,
            ) as PlaylistBase;  // 显式转换为 PlaylistBase
            
            final result = (
              count: entry.value.length,
              playlist: playlist,
            );
            return result;
          })
          .sorted((a, b) => b.count.compareTo(a.count))
          .toList();
    }
}

final historyTopPlaylistsProvider = AsyncNotifierProviderFamily<
    HistoryTopPlaylistsNotifier,
    HistoryTopPlaylistsState,
    HistoryDuration>(() => HistoryTopPlaylistsNotifier());
