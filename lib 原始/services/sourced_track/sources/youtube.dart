import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:http/http.dart';

import 'package:spotube/models/database/database.dart';


import 'package:spotube/services/logger/logger.dart';
import 'package:spotube/services/song_link/song_link.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/exceptions.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/sourced_track/models/video_info.dart';
import 'package:spotube/services/base/sourced_track.dart';

import 'package:spotube/utils/service_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final youtubeClient = YoutubeExplode();
final officialMusicRegex = RegExp(
  r"official\s(video|audio|music\svideo|lyric\svideo|visualizer)",
  caseSensitive: false,
);

// 在文件顶部添加数据库单例
final _databaseInstance = AppDatabase();

class YoutubeSourceInfo extends SourceInfo {
  YoutubeSourceInfo({
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

class YoutubeSourcedTrack extends SourcedTrack {
  // 构造函数和所有 override 方法保持不变
  YoutubeSourcedTrack({
    required super.source,
    required super.siblings,
    required super.sourceInfo,
    required super.track,
  });

  // 实现 SourceableTrack 的所有必需方法
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
    final database = _databaseInstance;  // 使用文件级别的单例
    final cachedSource = await (database.select(database.sourceMatchTable)
          ..where((s) => s.trackId.equals(track.id))
          ..limit(1)
          ..orderBy([
            (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .get()
        .then((s) => s.firstOrNull);

    if (cachedSource == null || cachedSource.sourceType != SourceType.youtube) {
      // 移除 ref 参数
      final siblings = await fetchSiblings(track: track);
      if (siblings.isEmpty) {
        throw TrackNotFoundError(track);
      }

      await database.into(database.sourceMatchTable).insert(
            SourceMatchTableCompanion.insert(
              trackId: track.id,  // 修改这里
              sourceId: siblings.first.info.id,
              sourceType: const Value(SourceType.youtube),
            ),
          );

      return YoutubeSourcedTrack(
       
        siblings: siblings.map((s) => s.info).skip(1).toList(),
        source: siblings.first.source as SourceMap,
        sourceInfo: siblings.first.info,
        track: track,
      );
    }
    final item = await youtubeClient.videos.get(cachedSource.sourceId);
    final manifest = await youtubeClient.videos.streamsClient
        .getManifest(
          cachedSource.sourceId,
        )
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw ClientException("Timeout"),
        );
    return YoutubeSourcedTrack(
     
      siblings: [],
      source: toSourceMap(manifest),
      sourceInfo: YoutubeSourceInfo(
        id: item.id.value,
        artist: item.author,
        artistUrl: "https://www.youtube.com/channel/${item.channelId}",
        pageUrl: item.url,
        thumbnail: item.thumbnails.highResUrl,
        title: item.title,
        duration: item.duration ?? Duration.zero,
        album: null,
      ),
      track: track,
    );
  }

  static SourceMap toSourceMap(StreamManifest manifest) {
    var m4a = manifest.audioOnly
        .where((audio) => audio.codec.mimeType == "audio/mp4")
        .sortByBitrate();

    var weba = manifest.audioOnly
        .where((audio) => audio.codec.mimeType == "audio/webm")
        .sortByBitrate();

    m4a = m4a.isEmpty ? weba.toList() : m4a;
    weba = weba.isEmpty ? m4a.toList() : weba;

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
      final manifest =
          await youtubeClient.videos.streamsClient.getManifest(item.id).timeout(
                const Duration(seconds: 5),
                onTimeout: () => throw ClientException("Timeout"),
              );
      sourceMap = toSourceMap(manifest);
    }

    final SiblingType sibling = (
      info: YoutubeSourceInfo(
        id: item.id,
        artist: item.channelName,
        artistUrl: "https://www.youtube.com/channel/${item.channelId}",
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

  static List<YoutubeVideoInfo> rankResults(
      List<YoutubeVideoInfo> results, SourceableTrack track) {
    // 获取艺术家列表
    final artists = [track.artistName];

    return results
        .sorted((a, b) => b.views.compareTo(a.views))
        .map((sibling) {
          int score = 0;

          for (final artist in artists) {
            final isSameChannelArtist =
                sibling.channelName.toLowerCase() == artist.toLowerCase();
            final channelContainsArtist = sibling.channelName
                .toLowerCase()
                .contains(artist.toLowerCase());

            if (isSameChannelArtist || channelContainsArtist) {
              score += 1;
            }

            final titleContainsArtist =
                sibling.title.toLowerCase().contains(artist.toLowerCase());

            if (titleContainsArtist) {
              score += 1;
            }
          }

          final titleContainsTrackName =
              sibling.title.toLowerCase().contains(track.title.toLowerCase());

          final hasOfficialFlag =
              officialMusicRegex.hasMatch(sibling.title.toLowerCase());

          if (titleContainsTrackName) {
            score += 3;
          }

          if (hasOfficialFlag) {
            score += 1;
          }

          if (hasOfficialFlag && titleContainsTrackName) {
            score += 2;
          }

          return (sibling: sibling, score: score);
        })
        .sorted((a, b) => b.score.compareTo(a.score))
        .map((e) => e.sibling)
        .toList();
  }

  static Future<List<SiblingType>> fetchSiblings({
    required SourceableTrack track,
  }) async {
    // 移除 ref 参数
    final searchQuery = track.getSearchTerm();  // 使用 SourceableTrack 的方法

    final links = await SongLinkService.links(track.id);
    final ytLink = links.firstWhereOrNull((link) => link.platform == "youtube");

    if (ytLink?.url != null
        // allows to fetch siblings more results for already sourced track
        &&
        track is! SourcedTrack) {
      try {
        return [
          await toSiblingType(
            0,
            YoutubeVideoInfo.fromVideo(
              await youtubeClient.videos.get(ytLink!.url!),
            ),
          )
        ];
      } on VideoUnplayableException catch (e, stack) {
        // Ignore this error and continue with the search
        AppLogger.reportError(e, stack);
      }
    }

    //final query = SourcedTrack.getSearchTerm(track);

    final searchResults = await youtubeClient.search.search(
      "$searchQuery - Topic",
      filter: TypeFilters.video,
    );

    if (ServiceUtils.onlyContainsEnglish(searchQuery)) {
      return await Future.wait(searchResults
          .map(YoutubeVideoInfo.fromVideo)
          .mapIndexed(toSiblingType));
    }

    final rankedSiblings = rankResults(
      searchResults.map(YoutubeVideoInfo.fromVideo).toList(),
      track,
    );

    return await Future.wait(rankedSiblings.mapIndexed(toSiblingType));
  }

  Future<YoutubeSourcedTrack?> swapWithSibling(SourceInfo sibling) async {
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

    final manifest = await youtubeClient.videos.streamsClient
        .getManifest(newSourceInfo.id)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw ClientException("Timeout"),
        );

    // 使用全局单例
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

    return YoutubeSourcedTrack(
     
      siblings: newSiblings,
      source: toSourceMap(manifest),
      sourceInfo: newSourceInfo,
      track: this,
    );
  }

  Future<YoutubeSourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(track: this);

    return YoutubeSourcedTrack(
     
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
