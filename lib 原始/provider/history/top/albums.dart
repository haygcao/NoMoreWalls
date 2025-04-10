

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/provider/history/top.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/album.dart';

// 定义基础状态类
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

typedef PlaybackHistoryAlbum = ({int count, AlbumBase album});

// 修改继承关系
class HistoryTopAlbumsState implements PaginatedState {
  @override
  final List<PlaybackHistoryAlbum> items;
  @override
  final int offset;
  @override
  final int limit;
  @override
  final bool hasMore;

  HistoryTopAlbumsState({
    required this.items,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  HistoryTopAlbumsState copyWith({
    List<PlaybackHistoryAlbum>? items,
    int? offset,
    int? limit,
    bool? hasMore,
  }) {
    return HistoryTopAlbumsState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// 修改 Notifier 类
class HistoryTopAlbumsNotifier extends FamilyAsyncNotifier<HistoryTopAlbumsState, HistoryDuration> {
  @override
  Future<HistoryTopAlbumsState> build(HistoryDuration arg) async {
    final (items: albums, hasMore: hasMore, nextOffset: nextOffset) = 
        await fetch(arg, 0, 20);

    final subscription = createAlbumsQuery(arg).watch().listen((event) {
      if (!state.hasValue) return;
      state = AsyncValue.data(state.value!.copyWith(
        items: getAlbumsWithCount(event),
        hasMore: false,
      ));
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return HistoryTopAlbumsState(
      items: albums,
      offset: nextOffset,
      limit: 20,
      hasMore: hasMore,
    );
  }

  Selectable<AlbumBase> createAlbumsQuery(HistoryDuration duration, {int? limit, int? offset}) {
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
    return database.customSelect(
      """
        SELECT history_table.data
        FROM history_table 
        WHERE type = 'album' AND
              created_at >= datetime($durationStr)
        ORDER BY created_at desc
        ${limit != null && offset != null ? 'LIMIT $limit OFFSET $offset' : ''}
      """,
      readsFrom: {database.historyTable},
    ).map((row) {
      final data = row.read<Map<String, dynamic>>('data');
      return Album(
        id: data['id'] as String,
        name: data['name'] as String,
        uri: data['uri'] as String,
        description: data['description'] as String?,
        imageUrl: data['imageUrl'] as String?,
        releaseDate: data['releaseDate'] != null 
            ? DateTime.parse(data['releaseDate']) 
            : null,
        artists: data['artists'] != null 
            ? List<String>.from(data['artists']) 
            : null,
        platformMetadata: data['platformMetadata'] as Map<String, dynamic>?,
      );
    });
  }

  Future<({
    List<PlaybackHistoryAlbum> items,
    bool hasMore,
    int nextOffset,
  })> fetch(HistoryDuration duration, int offset, int limit) async {
    final albumsQuery = createAlbumsQuery(duration, limit: limit, offset: offset);
    final items = getAlbumsWithCount(await albumsQuery.get());

    return (
      items: items,
      hasMore: items.length == limit,
      nextOffset: offset + limit,
    );
  }
  Future<void> fetchMore() async {
      final currentState = state.value;
      if (currentState == null || !currentState.hasMore) return;
  
      // 修复类型转换问题
      state = const AsyncValue.loading().copyWithPrevious(state) as AsyncValue<HistoryTopAlbumsState>;
      
      try {
        final (items: newItems, hasMore: hasMore, nextOffset: nextOffset) = 
            await fetch(arg, currentState.offset, currentState.limit);
            
        state = AsyncData(currentState.copyWith(
          items: [...currentState.items, ...newItems],
          offset: nextOffset,
          hasMore: hasMore,
        ));
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  // 修改参数类型为 AlbumBase
  List<PlaybackHistoryAlbum> getAlbumsWithCount(
    List<AlbumBase> albumsWithTrackAlbums,
  ) {
    return groupBy(albumsWithTrackAlbums, (album) => album.id)
        .entries
        .map((entry) {
          return (count: entry.value.length, album: entry.value.first);
        })
        .sorted((a, b) => b.count.compareTo(a.count))
        .toList();
  }
}

final historyTopAlbumsProvider = AsyncNotifierProviderFamily<
    HistoryTopAlbumsNotifier,
    HistoryTopAlbumsState,
    HistoryDuration>(() => HistoryTopAlbumsNotifier());
