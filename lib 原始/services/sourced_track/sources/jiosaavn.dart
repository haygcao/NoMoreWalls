import 'package:collection/collection.dart';
import 'package:drift/drift.dart';


import 'package:spotube/models/database/database.dart';

import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/exceptions.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:jiosaavn/jiosaavn.dart';
import 'package:spotube/extensions/string.dart';

// 添加全局单例
final _databaseInstance = AppDatabase();
final jiosaavnClient = JioSaavnClient();

class JioSaavnSourceInfo extends SourceInfo {
  JioSaavnSourceInfo({
    required super.id,
    required super.title,
    required super.artist,
    required super.thumbnail,
    required super.pageUrl,
    required super.duration,
    required super.artistUrl,
    required super.album,
  });
}

class JioSaavnSourcedTrack extends SourcedTrack {
  JioSaavnSourcedTrack({
    // 移除 ref 参数
    required super.source,
    required super.siblings,
    required super.sourceInfo,
    required super.track,
  });

  // 实现 SourceableTrack 接口
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
  String? get thumbnailUrl => sourceInfo.thumbnail;

  @override
  String? get artistId => track.artistId;

  @override
  String? get albumId => track.albumId;

  @override
  String getSearchTerm() => track.getSearchTerm();

  @override
  Map<String, dynamic> toJson() => {
        ...track.toJson(),
        'source': source.toJson(),
        'sourceInfo': sourceInfo.toJson(),
        'siblings': siblings.map((s) => s.toJson()).toList(),
      };

  static Future<SourcedTrack> fetchFromTrack({
    required SourceableTrack track,
    bool weakMatch = false,
  }) async {
    final database = _databaseInstance;
    final cachedSource = await (database.select(database.sourceMatchTable)
          ..where((s) => s.trackId.equals(track.id!))
          ..limit(1)
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .getSingleOrNull();

    if (cachedSource == null ||
        cachedSource.sourceType != SourceType.jiosaavn) {
      final siblings = await fetchSiblings(track: track, weakMatch: weakMatch);

      if (siblings.isEmpty) {
        throw TrackNotFoundError(track);
      }

      await database.into(database.sourceMatchTable).insert(
            SourceMatchTableCompanion.insert(
              trackId: track.id!,
              sourceId: siblings.first.info.id,
              sourceType: const Value(SourceType.jiosaavn),
            ),
          );

      return JioSaavnSourcedTrack(
        siblings: siblings.map((s) => s.info).skip(1).toList(),
        source: siblings.first.source!,
        sourceInfo: siblings.first.info,
        track: track,
      );
    }

    final [item] = await jiosaavnClient.songs.detailsById([cachedSource.sourceId]);
    final (:info, :source) = toSiblingType(item);

    return JioSaavnSourcedTrack(
      siblings: [],
      source: source!,
      sourceInfo: info,
      track: track,
    );
  }

  // 恢复原有的 toSiblingType 方法
  static SiblingType toSiblingType(SongResponse result) {
    final SiblingType sibling = (
      info: JioSaavnSourceInfo(
        artist: [
          result.primaryArtists,
          if (result.featuredArtists.isNotEmpty) ", ",
          result.featuredArtists
        ].join("").unescapeHtml(),
        artistUrl:
            "https://www.jiosaavn.com/artist/${result.primaryArtistsId.split(",").firstOrNull ?? ""}",
        duration: Duration(seconds: int.parse(result.duration)),
        id: result.id,
        pageUrl: result.url,
        thumbnail: result.image?.last.link ?? "",
        title: result.name!.unescapeHtml(),
        album: result.album.name,
      ),
      source: SourceMap(
        m4a: SourceQualityMap(
          high: result.downloadUrl!
              .firstWhere((element) => element.quality == "320kbps")
              .link,
          medium: result.downloadUrl!
              .firstWhere((element) => element.quality == "160kbps")
              .link,
          low: result.downloadUrl!
              .firstWhere((element) => element.quality == "96kbps")
              .link,
        ),
      ),
    );

    return sibling;
  }

  static Future<List<SiblingType>> fetchSiblings({
    required SourceableTrack track,
    bool weakMatch = false,
  }) async {
    final searchQuery = track.getSearchTerm();

    final SongSearchResponse(:results) =
        await jiosaavnClient.search.songs(searchQuery, limit: 20);

    final matchedResults = results
        .where(
          (s) {
            s.name?.unescapeHtml().contains(track.title) ?? false;  // 使用 title

            final sameName = s.name?.unescapeHtml() == track.title;  // 使用 title
            final artistNames = [
              s.primaryArtists,
              if (s.featuredArtists.isNotEmpty) ", ",
              s.featuredArtists
            ].join("").unescapeHtml();
            
            // 使用 artistName
            final sameArtist = artistNames.split(", ")
                .any((artist) => artist.toLowerCase() == track.artistName.toLowerCase());

            if (weakMatch) {
              final containsName =
                  s.name?.unescapeHtml().contains(track.title) ?? false;  // 使用 title
              final containsPrimaryArtist = s.primaryArtists
                  .unescapeHtml()
                  .contains(track.artistName);  // 使用 artistName

              return containsName && containsPrimaryArtist;
            }

            return sameName && sameArtist;
          },
        )
        .map(toSiblingType)
        .toList();

    if (weakMatch && matchedResults.isEmpty) {
      return results.map(toSiblingType).toList();
    }

    return matchedResults;
  }

  @override
  Future<JioSaavnSourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(track: this);

    return JioSaavnSourcedTrack(
      siblings: fetchedSiblings
          .where((s) => s.info.id != sourceInfo.id)
          .map((s) => s.info)
          .toList(),
      source: source,
      sourceInfo: sourceInfo,
      track: this,
    );
  }

  @override
  Future<JioSaavnSourcedTrack?> swapWithSibling(SourceInfo sibling) async {
    if (sibling.id == sourceInfo.id) {
      return null;
    }

    final isStepSibling = siblings.none((s) => s.id == sibling.id);
    final newSourceInfo = isStepSibling
        ? sibling
        : siblings.firstWhere((s) => s.id == sibling.id);
    final newSiblings = siblings.where((s) => s.id != sibling.id).toList()
      ..insert(0, sourceInfo);

    final [item] = await jiosaavnClient.songs.detailsById([newSourceInfo.id]);
    final (:info, :source) = toSiblingType(item);

    final database = _databaseInstance;
    await database.into(database.sourceMatchTable).insert(
          SourceMatchTableCompanion.insert(
            trackId: id!,
            sourceId: info.id,
            sourceType: const Value(SourceType.jiosaavn),
            createdAt: Value(DateTime.now()),
          ),
          mode: InsertMode.replace,
        );

    return JioSaavnSourcedTrack(
      siblings: newSiblings,
      source: source!,
      sourceInfo: info,
      track: this,
    );
  }

  @override
  String getDisplayName() => "$title - $artistName";

  @override
  String getDescription() => albumName ?? sourceInfo.artist;

  @override
  Map<String, dynamic> toMediaItem() => {
    'id': id,
    'title': title,
    'artist': artistName,
    'album': albumName,
    'duration': duration.inMilliseconds,
    'artUri': thumbnailUrl,
  };
}
