import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/exceptions.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/sourced_track/models/video_info.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:invidious/invidious.dart';
import 'package:spotube/services/sourced_track/sources/youtube.dart';
import 'package:spotube/utils/service_utils.dart';
import 'package:spotube/services/song_link/song_link.dart'; // 添加 SongLink 导入
import 'package:spotube/services/logger/logger.dart'; // 添加日志导入

// 保留原有的 provider 定义
final invidiousProvider = Provider<InvidiousClient>(
  (ref) {
    final invidiousInstance = ref.watch(
      userPreferencesProvider.select((s) => s.invidiousInstance),
    );
    return InvidiousClient(server: invidiousInstance);
  },
);

// 添加全局单例
final _databaseInstance = AppDatabase();
// 使用默认的 Invidious 实例
final _invidiousClient = InvidiousClient(server: "https://pipedapi.kavin.rocks");

class InvidiousSourceInfo extends SourceInfo {
  InvidiousSourceInfo({
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

class InvidiousSourcedTrack extends SourcedTrack {
  InvidiousSourcedTrack({
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
    required SourceableTrack track,  // 修改这里
    bool weakMatch = false,
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
    final invidiousClient = _invidiousClient;

    if (cachedSource == null) {
      final siblings = await fetchSiblings(track: track);
      if (siblings.isEmpty) {
        throw TrackNotFoundError(track);
      }

      await database.into(database.sourceMatchTable).insert(
            SourceMatchTableCompanion.insert(
              trackId: track.id!,
              sourceId: siblings.first.info.id,
              sourceType: const Value(SourceType.youtube),
            ),
          );

      return InvidiousSourcedTrack(
        siblings: siblings.map((s) => s.info).skip(1).toList(),
        source: siblings.first.source as SourceMap,
        sourceInfo: siblings.first.info,
        track: track,
      );
    } else {
      final manifest =
          await invidiousClient.videos.get(cachedSource.sourceId, local: true);

      return InvidiousSourcedTrack(
        siblings: [],
        source: toSourceMap(manifest),
        sourceInfo: InvidiousSourceInfo(
          id: manifest.videoId,
          artist: manifest.author,
          artistUrl: manifest.authorUrl,
          pageUrl: "https://www.youtube.com/watch?v=${manifest.videoId}",
          thumbnail: manifest.videoThumbnails.first.url,
          title: manifest.title,
          duration: Duration(seconds: manifest.lengthSeconds),
          album: null,
        ),
        track: track,
      );
    }
  }

  static SourceMap toSourceMap(InvidiousVideoResponse manifest) {
    final m4a = manifest.adaptiveFormats
        .where((audio) => audio.type.contains("audio/mp4"))
        .sorted((a, b) => int.parse(a.bitrate).compareTo(int.parse(b.bitrate)));

    final weba = manifest.adaptiveFormats
        .where((audio) => audio.type.contains("audio/webm"))
        .sorted((a, b) => int.parse(a.bitrate).compareTo(int.parse(b.bitrate)));

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
    InvidiousClient invidiousClient,
  ) async {
    SourceMap? sourceMap;
    if (index == 0) {
      final manifest = await invidiousClient.videos.get(item.id, local: true);
      sourceMap = toSourceMap(manifest);
    }

    final SiblingType sibling = (
      info: InvidiousSourceInfo(
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
    final invidiousClient = _invidiousClient;
    
    // 添加 SongLink 支持
    final links = await SongLinkService.links(track.id);
    final ytLink = links.firstWhereOrNull((link) => link.platform == "youtube");

    if (ytLink != null && track is! SourcedTrack) {
      try {
        final videoId = Uri.parse(ytLink.url!).queryParameters["v"]!;
        final manifest = await invidiousClient.videos.get(videoId, local: true);

        return [
          await toSiblingType(
            0,
            YoutubeVideoInfo.fromVideoResponse(manifest, SearchMode.youtube),
            invidiousClient,
          )
        ];
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    }
    
    final searchQuery = track.getSearchTerm();

    final searchResults = await invidiousClient.search.list(
      searchQuery,
      type: InvidiousSearchType.video,
    );

    if (ServiceUtils.onlyContainsEnglish(searchQuery)) {
      return await Future.wait(
        searchResults
            .whereType<InvidiousSearchResponseVideo>()
            .map(
              (result) => YoutubeVideoInfo.fromSearchResponse(
                result,
                SearchMode.youtube,
              ),
            )
            .mapIndexed((i, r) => toSiblingType(i, r, invidiousClient)),
      );
    }

    final rankedSiblings = YoutubeSourcedTrack.rankResults(
      searchResults
          .whereType<InvidiousSearchResponseVideo>()
          .map(
            (result) => YoutubeVideoInfo.fromSearchResponse(
              result,
              SearchMode.youtube,
            ),
          )
          .toList(),
      track,
    );

    return await Future.wait(
      rankedSiblings.mapIndexed((i, r) => toSiblingType(i, r, invidiousClient)),
    );
  }

  @override
  Future<SourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(track: this);

    return InvidiousSourcedTrack(
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
  Future<SourcedTrack?> swapWithSibling(SourceInfo sibling) async {
    if (sibling.id == sourceInfo.id) {
      return null;
    }

    final isStepSibling = siblings.none((s) => s.id == sibling.id);
    final newSourceInfo = isStepSibling
        ? sibling
        : siblings.firstWhere((s) => s.id == sibling.id);
    final newSiblings = siblings.where((s) => s.id != sibling.id).toList()
      ..insert(0, sourceInfo);

    final manifest = await _invidiousClient.videos.get(newSourceInfo.id, local: true);

    final database = _databaseInstance;
    await database.into(database.sourceMatchTable).insert(
          SourceMatchTableCompanion.insert(
            trackId: id!,
            sourceId: newSourceInfo.id,
            sourceType: const Value(SourceType.youtube),
            createdAt: Value(DateTime.now()),
          ),
          mode: InsertMode.replace,
        );

    return InvidiousSourcedTrack(
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
