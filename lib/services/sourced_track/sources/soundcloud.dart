import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 移除 spotify 导入，改用 sourceable_track
import 'package:spotube/models/database/database.dart';
import 'package:spotube/services/logger/logger.dart';
import 'package:spotube/services/song_link/song_link.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/exceptions.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart'
    as soundcloud;

// 添加全局数据库实例
final _databaseInstance = AppDatabase();
// 添加全局 SoundCloud 客户端
final _soundcloudClient = soundcloud.SoundcloudClient();

// 保留原有的 provider 定义
final soundcloudProvider = Provider<soundcloud.SoundcloudClient>(
  (ref) {
    return soundcloud.SoundcloudClient();
  },
);

class SoundcloudSourceInfo extends SourceInfo {
  SoundcloudSourceInfo({
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

class SoundcloudSourcedTrack extends SourcedTrack {
  SoundcloudSourcedTrack({
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
    // Indicates a stream url refresh
    if (track is SoundcloudSourcedTrack) {
      final manifest = await _soundcloudClient.tracks
          .getStreams(int.parse(track.sourceInfo.id));

      return SoundcloudSourcedTrack(
        siblings: track.siblings,
        source: toSourceMap(manifest),
        sourceInfo: track.sourceInfo,
        track: track,
      );
    }

    final database = _databaseInstance;
    final cachedSource = await (database.select(database.sourceMatchTable)
          ..where((s) => s.trackId.equals(track.id))
          ..limit(1)
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .getSingleOrNull();

    if (cachedSource == null ||
        cachedSource.sourceType != SourceType.soundcloud) {
      final siblings = await fetchSiblings(track: track);
      if (siblings.isEmpty) {
        throw TrackNotFoundError(track);
      }

      await database.into(database.sourceMatchTable).insert(
            SourceMatchTableCompanion.insert(
              trackId: track.id,
              sourceId: siblings.first.info.id,
              sourceType: const Value(SourceType.soundcloud),
            ),
          );

      return SoundcloudSourcedTrack(
        siblings: siblings.map((s) => s.info).skip(1).toList(),
        source: siblings.first.source as SourceMap,
        sourceInfo: siblings.first.info,
        track: track,
      );
    } else {
      final details = await _soundcloudClient.tracks.get(
        int.parse(cachedSource.sourceId),
      );
      final streams = await _soundcloudClient.tracks.getStreams(
        int.parse(cachedSource.sourceId),
      );

      return SoundcloudSourcedTrack(
        siblings: [],
        source: toSourceMap(streams),
        sourceInfo: SoundcloudSourceInfo(
          id: details.id.toString(),
          artist: details.user.username,
          artistUrl: details.user.permalinkUrl.toString(),
          pageUrl: details.permalinkUrl.toString(),
          thumbnail: details.artworkUrl.toString(),
          title: details.title,
          duration: Duration(seconds: details.duration.toInt()),
          album: null,
        ),
        track: track,
      );
    }
  }

  static SourceMap toSourceMap(List<soundcloud.StreamInfo> manifest) {
    // Fix: Use string comparison instead of enum
    final m4a = manifest
        .where((audio) => audio.container == "mp3")
        .sorted((a, b) {
      return a.quality == soundcloud.Quality.highQuality ? 1 : -1;
    });

    final weba = manifest
        .where((audio) => audio.container == "ogg")
        .sorted((a, b) {
      return a.quality == soundcloud.Quality.highQuality ? 1 : -1;
    });

    return SourceMap(
      m4a: m4a.isNotEmpty
          ? SourceQualityMap(
              high: m4a.first.url.toString(),
              medium: (m4a.elementAtOrNull(m4a.length ~/ 2) ?? m4a.firstOrNull ?? m4a.first).url.toString(),
              low: m4a.lastOrNull?.url.toString() ?? m4a.first.url.toString(),
            )
          : null,
      weba: weba.isNotEmpty
          ? SourceQualityMap(
              high: weba.first.url.toString(),
              medium: (weba.elementAtOrNull(weba.length ~/ 2) ?? weba.firstOrNull ?? weba.first)
                  .url
                  .toString(),
              low: weba.lastOrNull?.url.toString() ?? weba.first.url.toString(),
            )
          : null,
    );
  }

  static Future<SiblingType> toSiblingType(
    int index,
    dynamic item, // 改为 dynamic 类型以接受不同类型的参数
  ) async {
    SourceMap? sourceMap;
    if (index == 0) {
      final id = item is soundcloud.Track ? item.id : item.id;
      final manifest = await _soundcloudClient.tracks.getStreams(id);
      sourceMap = toSourceMap(manifest);
    }

    final user = item is soundcloud.Track ? item.user : item.user;
    final permalinkUrl = item is soundcloud.Track ? item.permalinkUrl : item.permalinkUrl;
    final artworkUrl = item is soundcloud.Track ? item.artworkUrl : item.artworkUrl;
    final title = item is soundcloud.Track ? item.title : item.title;
    final duration = item is soundcloud.Track ? item.duration : item.duration;

    final SiblingType sibling = (
      info: SoundcloudSourceInfo(
        id: item.id.toString(),
        artist: user.username,
        artistUrl: permalinkUrl.toString(),
        pageUrl: permalinkUrl.toString(),
        thumbnail: artworkUrl.toString(),
        title: title,
        duration: Duration(seconds: duration.toInt()),
        album: null,
      ),
      source: sourceMap,
    );

    return sibling;
  }

  static Future<List<SiblingType>> fetchSiblings({
    required SourceableTrack track,
  }) async {
    final links = await SongLinkService.links(track.id);
    final soundcloudLink =
        links.firstWhereOrNull((link) => link.platform == "soundcloud");

    if (soundcloudLink != null && track is! SourcedTrack) {
      try {
        final details =
            await _soundcloudClient.tracks.getByUrl(soundcloudLink.url!);

        return [
          await toSiblingType(
            0,
            details,
          )
        ];
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    }

    final query = track.getSearchTerm();

    final searchResults = await _soundcloudClient.search
        .getTracks(query, offset: 0, limit: 10)
        .toList()
        .then((value) => value.expand((e) => e).toList());

    return await Future.wait(
      searchResults.mapIndexed(
        (i, r) => toSiblingType(
          i,
          soundcloud.Track(
            id: r.id,
            title: r.title,
            duration: r.duration,
            user: r.user,
            artworkUrl: r.artworkUrl,
            permalinkUrl: r.permalinkUrl,
            caption: r.caption,
            commentCount: r.commentCount,
            createdAt: r.createdAt,
            description: r.description,
            downloadCount: r.downloadCount,
            genre: r.genre,
            commentable: r.commentable,
            fullDuration: r.fullDuration,
            labelName: r.labelName,
            lastModified: r.lastModified,
            license: r.license,
            likesCount: r.likesCount,
            monetizationModel: r.monetizationModel,
            playbackCount: r.playbackCount,
            policy: r.policy,
            purchaseTitle: r.purchaseTitle,
            purchaseUrl: r.purchaseUrl,
            repostsCount: r.repostsCount,
            tagList: r.tagList,
            waveformUrl: r.waveformUrl,
          ),
        ),
      ),
    );
  }

  @override
  Future<SourcedTrack> copyWithSibling() async {
    if (siblings.isNotEmpty) {
      return this;
    }
    final fetchedSiblings = await fetchSiblings(track: this);

    return SoundcloudSourcedTrack(
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

    // a sibling source that was fetched from the search results
    final isStepSibling = siblings.none((s) => s.id == sibling.id);

    final newSourceInfo = isStepSibling
        ? sibling
        : siblings.firstWhere((s) => s.id == sibling.id);
    final newSiblings = siblings.where((s) => s.id != sibling.id).toList()
      ..insert(0, sourceInfo);

    final manifest = await _soundcloudClient.tracks.getStreams(
      int.parse(newSourceInfo.id),
    );

    final database = _databaseInstance;
    await database.into(database.sourceMatchTable).insert(
          SourceMatchTableCompanion.insert(
            trackId: id,
            sourceId: newSourceInfo.id,
            sourceType: const Value(SourceType.soundcloud),
            // Because we're sorting by createdAt in the query
            // we have to update it to indicate priority
            createdAt: Value(DateTime.now()),
          ),
          mode: InsertMode.replace,
        );

    return SoundcloudSourcedTrack(
      siblings: newSiblings,
      source: toSourceMap(manifest),
      sourceInfo: newSourceInfo,
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