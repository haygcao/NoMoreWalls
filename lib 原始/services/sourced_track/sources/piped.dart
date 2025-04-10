import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:piped_client/piped_client.dart';

import 'package:spotube/models/database/database.dart';

import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/exceptions.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/sourced_track/models/video_info.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:spotube/services/sourced_track/sources/youtube.dart';
import 'package:spotube/utils/service_utils.dart';
import 'package:spotube/services/song_link/song_link.dart'; // 添加 SongLink 导入
import 'package:spotube/services/logger/logger.dart'; // 添加日志导入

// 保留原有的 provider 定义
final pipedProvider = Provider<PipedClient>(
  (ref) {
    final instance =
        ref.watch(userPreferencesProvider.select((s) => s.pipedInstance));
    return PipedClient(instance: instance);
  },
);

// 添加全局数据库实例
final _databaseInstance = AppDatabase();
// 添加全局 PipedClient 实例，但不硬编码实例 URL
final _pipedClient = PipedClient();
// 添加默认搜索模式
const _searchMode = SearchMode.youtube;

class PipedSourceInfo extends SourceInfo {
  PipedSourceInfo({
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

class PipedSourcedTrack extends SourcedTrack {
  PipedSourcedTrack({
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
  }) async {
    final database = _databaseInstance;
    final cachedSource = await (database.select(database.sourceMatchTable)
          ..where((s) => s.trackId.equals(track.id))
          ..limit(1)
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .getSingleOrNull();
    
    final pipedClient = _pipedClient;

    if (cachedSource == null) {
      final siblings = await fetchSiblings(track: track);
      if (siblings.isEmpty) {
        throw TrackNotFoundError(track);
      }

      await database.into(database.sourceMatchTable).insert(
            SourceMatchTableCompanion.insert(
              trackId: track.id,
              sourceId: siblings.first.info.id,
              sourceType: const Value(
                _searchMode == SearchMode.youtube
                    ? SourceType.youtube
                    : SourceType.youtubeMusic,
              ),
            ),
          );

      return PipedSourcedTrack(
        siblings: siblings.map((s) => s.info).skip(1).toList(),
        source: siblings.first.source as SourceMap,
        sourceInfo: siblings.first.info,
        track: track,
      );
    } else {
      final manifest = await pipedClient.streams(cachedSource.sourceId);

      return PipedSourcedTrack(
        siblings: [],
        source: toSourceMap(manifest),
        sourceInfo: PipedSourceInfo(
          id: manifest.id,
          artist: manifest.uploader,
          artistUrl: manifest.uploaderUrl,
          pageUrl: "https://www.youtube.com/watch?v=${manifest.id}",
          thumbnail: manifest.thumbnailUrl,
          title: manifest.title,
          duration: manifest.duration,
          album: null,
        ),
        track: track,
      );
    }
  }

  static SourceMap toSourceMap(PipedStreamResponse manifest) {
    // 此方法不需要修改，保持原样
    final m4a = manifest.audioStreams
        .where((audio) => audio.format == PipedAudioStreamFormat.m4a)
        .sorted((a, b) => a.bitrate.compareTo(b.bitrate));

    final weba = manifest.audioStreams
        .where((audio) => audio.format == PipedAudioStreamFormat.webm)
        .sorted((a, b) => a.bitrate.compareTo(b.bitrate));

    return SourceMap(
      m4a: SourceQualityMap(
        high: m4a.first.url.toString(),
        medium: (m4a.elementAtOrNull(m4a.length ~/ 2) ?? m4a[1]).url.toString(),
        low: m4a.last.url.toString(),
      ),
      weba: SourceQualityMap(
        high: weba.first.url.toString(),
        medium:
            (weba.elementAtOrNull(weba.length ~/ 2) ?? weba[1]).url.toString(),
        low: weba.last.url.toString(),
      ),
    );
  }

  static Future<SiblingType> toSiblingType(
    int index,
    YoutubeVideoInfo item,
  ) async {
    SourceMap? sourceMap;
    if (index == 0) {
      final manifest = await _pipedClient.streams(item.id);
      sourceMap = toSourceMap(manifest);
    }

    final SiblingType sibling = (
      info: PipedSourceInfo(
        id: item.id,
        artist: item.channelName,
        artistUrl: "https://www.youtube.com/${item.channelId}",
        pageUrl: "https://www.youtube.com/watch?v=${item.id}",
        thumbnail: item.thumbnailUrl,
        title: item.title,
        duration: item.duration,
        album: null,
      ),
      source: sourceMap,
    );

    return sibling;
  }

  static Future<List<SiblingType>> fetchSiblings({
    required SourceableTrack track,
  }) async {
    final pipedClient = _pipedClient;
    
    // 添加 SongLink 支持
    final links = await SongLinkService.links(track.id);
    final ytLink = links.firstWhereOrNull((link) => link.platform == "youtube");

    if (ytLink != null && track is! SourcedTrack) {
      try {
        final videoId = Uri.parse(ytLink.url!).queryParameters["v"]!;
        final manifest = await pipedClient.streams(videoId);

        return [
          await toSiblingType(
            0,
            YoutubeVideoInfo.fromStreamResponse(manifest, _searchMode),
          )
        ];
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    }
    
    final searchQuery = track.getSearchTerm();

    final PipedSearchResult(items: searchResults) = await pipedClient.search(
      searchQuery,
      _searchMode == SearchMode.youtube
          ? PipedFilter.videos
          : PipedFilter.musicSongs,
    );

    // when falling back to piped API make sure to use the YouTube mode
    const isYouTubeMusic = _searchMode == SearchMode.youtubeMusic;

    if (isYouTubeMusic) {
      final artist = track.artistName;

      return await Future.wait(
        searchResults
            .map(
              (result) => YoutubeVideoInfo.fromSearchItemStream(
                result as PipedSearchItemStream,
                _searchMode,
              ),
            )
            .sorted((a, b) => b.views.compareTo(a.views))
            .where(
              (item) => artist.toLowerCase() == item.channelName.toLowerCase(),
            )
            .mapIndexed((i, r) => toSiblingType(i, r)),
      );
    }

    if (ServiceUtils.onlyContainsEnglish(searchQuery)) {
      return await Future.wait(
        searchResults
            .whereType<PipedSearchItemStream>()
            .map(
              (result) => YoutubeVideoInfo.fromSearchItemStream(
                result,
                _searchMode,
              ),
            )
            .mapIndexed((i, r) => toSiblingType(i, r)),
      );
    }

    final rankedSiblings = YoutubeSourcedTrack.rankResults(
      searchResults
          .map(
            (result) => YoutubeVideoInfo.fromSearchItemStream(
              result as PipedSearchItemStream,
              _searchMode,
            ),
          )
          .toList(),
      track,
    );

    return await Future.wait(
      rankedSiblings.mapIndexed((i, r) => toSiblingType(i, r)),
    );
  }

  Future<SourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(track: this);

    return PipedSourcedTrack(
      siblings: fetchedSiblings
          .where((s) => s.info.id != sourceInfo.id)
          .map((s) => s.info)
          .toList(),
      source: source,
      sourceInfo: sourceInfo,
      track: this,
    );
  }

  Future<SourcedTrack?> swapWithSibling(SourceInfo sibling) async {
    if (sibling.id == sourceInfo.id) {
      return null;
    }

    // a sibling source that was fetched from the search results
    final isStepSibling = siblings.none((s) => s.id == sibling.id);

    final newSourceInfo = isStepSibling
        ? sibling
        : siblings.firstWhere((s) => s.id == sibling.id);
    final newSiblings = siblings.where((s) => s.id != sibling.id).toList()
      ..insert(0, sourceInfo);

    final manifest = await _pipedClient.streams(newSourceInfo.id);

    final database = _databaseInstance;
    await database.into(database.sourceMatchTable).insert(
          SourceMatchTableCompanion.insert(
            trackId: id,
            sourceId: newSourceInfo.id,
            sourceType: const Value(SourceType.youtube),
            // Because we're sorting by createdAt in the query
            // we have to update it to indicate priority
            createdAt: Value(DateTime.now()),
          ),
          mode: InsertMode.replace,
        );

    return PipedSourcedTrack(
      siblings: newSiblings,
      source: toSourceMap(manifest),
      sourceInfo: newSourceInfo,
      track: this,
    );
  }

  @override
  String getDisplayName() => "$title - $artistName";

  @override
  String getDescription() => sourceInfo.artist;

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
