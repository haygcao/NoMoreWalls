import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/provider/lyrics/base_lyrics_provider.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/models/database/database.dart';


abstract class BaseLyricsNotifier<T extends BaseTrack> extends FamilyAsyncNotifier<SubtitleSimple, T?> {
  // 将 track 改为 protected 方法
  @protected
  T get currentTrack => arg!;
  
  @protected
  List<BaseLyricsProvider<T>> getProviders();
  
  @override
  Future<SubtitleSimple> build(T? track) async {
    if (track == null) {
      throw "No track currently playing";
    }

    final database = ref.watch(databaseProvider);
    
    // 检查缓存
    final cachedLyrics = await (database.select(database.lyricsTable)
          ..where((tbl) => tbl.trackId.equals(track.id)))
        .map((row) => row.data)
        .getSingleOrNull();

    if (cachedLyrics != null) {
      return cachedLyrics;
    }

    // 尝试所有提供者
    SubtitleSimple? lyrics;
    final providers = getProviders();
    
    for (final provider in providers) {
      lyrics = await provider.getLyrics();
      if (lyrics != null && lyrics.lyrics.isNotEmpty) {
        break;
      }
    }

    if (lyrics == null || lyrics.lyrics.isEmpty) {
      throw Exception("无法找到歌词");
    }

    // 缓存歌词
    await database.into(database.lyricsTable).insert(
          LyricsTableCompanion.insert(
            trackId: track.id,
            data: lyrics,
          ),
          mode: InsertMode.replace,
        );

    return lyrics;
  }
}