
import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/models/spotify/track.dart';
// 移除这个导入，因为我们将使用 SourceManager 来获取偏好
// import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/sourced_track/exceptions.dart';
import 'package:spotube/services/sourced_track/models/source_info.dart';
import 'package:spotube/services/sourced_track/models/source_map.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/sourced_track/source_manager.dart';
import 'package:spotube/services/sourced_track/sources/invidious.dart';
import 'package:spotube/services/sourced_track/sources/jiosaavn.dart';
import 'package:spotube/services/sourced_track/sources/piped.dart';
import 'package:spotube/services/sourced_track/sources/soundcloud.dart';
import 'package:spotube/services/sourced_track/sources/youtube.dart';



// 移除这个错误的全局实例
// final _userPreferencesInstance = UserPreferences();

abstract class SourcedTrack implements SourceableTrack {
  final SourceableTrack track;
  final SourceMap source;
  final List<SourceInfo> siblings;
  final SourceInfo sourceInfo;

  SourcedTrack({
    required this.source,
    required this.siblings,
    required this.sourceInfo,
    required this.track,
  });

  // 添加 codec getter
  SourceCodecs get codec {
    final manager = SourceManager.instance;
    return manager.currentSource == AudioSource.jiosaavn
        ? SourceCodecs.m4a
        : manager.codec;
  }

  // 修改静态方法，直接使用 SourceManager 获取当前音频源
  static Future<SourcedTrack> fetchFromTrack({
    required SourceableTrack track,
  }) async {
    final manager = SourceManager.instance;
    final audioSource = manager.currentSource;

    try {
      return switch (audioSource) {
        AudioSource.youtube => await YoutubeSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.piped => await PipedSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.jiosaavn => await JioSaavnSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.invidious => await InvidiousSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.soundcloud => await SoundcloudSourcedTrack.fetchFromTrack(
            track: track,
          ),          
      };
    } catch (e) {
      if (e is TrackNotFoundError) {
        return await fetchFromTrackAltSource(track: track);
      }
      rethrow;
    }
  }

  // 修改静态方法，直接使用 SourceManager 获取当前音频源
  static Future<SourcedTrack> fetchFromTrackAltSource({
    required SourceableTrack track,
  }) async {
    final manager = SourceManager.instance;
    final audioSource = manager.currentSource;

    try {
      return switch (audioSource) {
        AudioSource.youtube => await PipedSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.piped => await PipedSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.jiosaavn => await JioSaavnSourcedTrack.fetchFromTrack(
            track: track,
          ),
        AudioSource.invidious => await InvidiousSourcedTrack.fetchFromTrack(
            track: track,
          ),
        // TODO: Handle this case.
        AudioSource.soundcloud => throw SoundcloudSourcedTrack.fetchFromTrack(
            track: track,
          ),
      };
    } catch (e) {
      if (e is TrackNotFoundError) {
        try {
          return await JioSaavnSourcedTrack.fetchFromTrack(
            track: track,
            weakMatch: true,
          );
        } catch (e) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  // 添加抽象方法
  Future<SourcedTrack> copyWithSibling();
  Future<SourcedTrack?> swapWithSibling(SourceInfo sibling);

  static SourcedTrack fromJson(Map<String, dynamic> json) {
    final manager = SourceManager.instance;
    final sourceInfo = SourceInfo.fromJson(json);
    final source = SourceMap.fromJson(json);
    final track = SpotifyTrack.fromTrack(Track.fromJson(json));
    final siblings = (json["siblings"] as List)
        .map((sibling) => SourceInfo.fromJson(sibling))
        .toList()
        .cast<SourceInfo>();

    return switch (manager.currentSource) {
      AudioSource.youtube => YoutubeSourcedTrack(
          source: source,
          siblings: siblings,
          sourceInfo: sourceInfo,
          track: track,
        ),
      AudioSource.piped => PipedSourcedTrack(
          source: source,
          siblings: siblings,
          sourceInfo: sourceInfo,
          track: track,
        ),
      AudioSource.jiosaavn => JioSaavnSourcedTrack(
          source: source,
          siblings: siblings,
          sourceInfo: sourceInfo,
          track: track,
        ),
      AudioSource.invidious => InvidiousSourcedTrack(
          source: source,
          siblings: siblings,
          sourceInfo: sourceInfo,
          track: track,
        ),
      // TODO: Handle this case.
      AudioSource.soundcloud => throw SoundcloudSourcedTrack(
          source: source,
          siblings: siblings,
          sourceInfo: sourceInfo,
          track: track,
        ),
    };
  }

  String get url {
    final manager = SourceManager.instance;
    final codec = manager.currentSource == AudioSource.jiosaavn
        ? SourceCodecs.m4a
        : manager.codec;

    return getUrlOfCodec(codec);
  }

  String getUrlOfCodec(SourceCodecs codec) {
    final quality = SourceManager.instance.quality;
    return source[codec]?[quality] ??
        source[codec == SourceCodecs.m4a ? SourceCodecs.weba : SourceCodecs.m4a][quality];
  }
}
