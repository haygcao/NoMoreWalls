import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:spotube/collections/assets.gen.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/video_info.dart';
import 'package:spotube/services/sourced_track/sources/invidious.dart';
import 'package:spotube/services/sourced_track/sources/jiosaavn.dart';
import 'package:spotube/services/sourced_track/sources/piped.dart';
import 'package:spotube/services/sourced_track/sources/soundcloud.dart'; // 添加 SoundCloud 导入
import 'package:spotube/services/sourced_track/sources/youtube.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:soundcloud_explode_dart/soundcloud_explode_dart.dart' as soundcloud;

// 导入 soundcloud.dart 中的全局客户端
final _soundcloudClient = soundcloud.SoundcloudClient();

class SourceManager {
  static final instance = SourceManager._();
  SourceManager._();

  late AudioSource _currentSource;
  late SourceQualities _quality;
  late SourceCodecs _codec;
  late Database _database;
  late String _pipedInstance;

  // 添加音源图标映射
  static final Map<Type, Widget> sourceIcons = {
    YoutubeSourceInfo:
        const Icon(SpotubeIcons.youtube, color: Color(0xFFFF0000)),
    JioSaavnSourceInfo: Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
        image: DecorationImage(
          image: Assets.jiosaavn.provider(),
          fit: BoxFit.cover,
        ),
      ),
    ),
    PipedSourceInfo: const Icon(SpotubeIcons.piped),
    InvidiousSourceInfo: Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
        image: DecorationImage(
          image: Assets.invidious.provider(),
          fit: BoxFit.cover,
        ),
      ),
    ),
    // 添加 SoundCloud 图标
    SoundcloudSourceInfo: Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: Assets.soundcloud.provider(), // 需要添加 SoundCloud 图标资源
          fit: BoxFit.cover,
        ),
      ),
    ),
  };

  void initialize({
    required AudioSource source,
    required SourceQualities quality,
    required SourceCodecs codec,
    required Database database,
    required String pipedInstance,
  }) {
    _currentSource = source;
    _quality = quality;
    _codec = codec;
    _database = database;
    _pipedInstance = pipedInstance;
  }

  AudioSource get currentSource => _currentSource;
  SourceQualities get quality => _quality;
  SourceCodecs get codec => _codec;
  Database get database => _database;
  String get pipedInstance => _pipedInstance;

  // 更新搜索方法以支持 SoundCloud
  Future<List<SourceInfo>> search(String query) async {
    switch (_currentSource) {
      case AudioSource.jiosaavn:
        final results = await jiosaavnClient.search.songs(query.trim());
        return Future.wait(
          results.results.mapIndexed((i, song) async {
            final siblingType = JioSaavnSourcedTrack.toSiblingType(song);
            return siblingType.info;
          }),
        );
      case AudioSource.soundcloud: // 添加 SoundCloud 搜索支持
        final searchResults = await _soundcloudClient.search
            .getTracks(query.trim(), offset: 0, limit: 10)
            .toList()
            .then((value) => value.expand((e) => e).toList());

        return Future.wait(
          searchResults.mapIndexed((i, track) async {
            final siblingType =
                await SoundcloudSourcedTrack.toSiblingType(i, track);
            return siblingType.info;
          }),
        );
      case AudioSource.youtube:
      case AudioSource.piped:
      case AudioSource.invidious:
      default:
        final results = await youtubeClient.search.search(query.trim());
        return Future.wait(
          results.map(YoutubeVideoInfo.fromVideo).mapIndexed((i, video) async {
            final siblingType =
                await YoutubeSourcedTrack.toSiblingType(i, video);
            return siblingType.info;
          }),
        );
    }
  }
}
