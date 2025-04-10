import 'dart:io';

import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';


import 'package:spotube/models/local_track.dart';
import 'package:spotube/models/parser/range_headers.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/audio_player/state.dart';

import 'package:spotube/provider/server/active_sourced_track.dart';
import 'package:spotube/provider/server/sourced_track.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/logger/logger.dart';
import 'package:spotube/services/sourced_track/enums.dart';
 // 添加这个导入
import 'package:spotube/services/base/sourced_track.dart';
import 'package:spotube/utils/service_utils.dart';

class ServerPlaybackRoutes {
  final Ref ref;
  UserPreferences get userPreferences => ref.read(userPreferencesProvider);
  AudioPlayerState get playlist => ref.read(audioPlayerProvider);
  final Dio dio;

  ServerPlaybackRoutes(this.ref) : dio = Dio();

  /// proxy hls playlist file
  Future<Response> proxyHls(String url, Map<String, dynamic> headers) async {
    try {
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      return Response.ok(
        response.data as Uint8List,
        headers: {
          "content-type": "audio/mpegurl",
          "content-length": (response.data as Uint8List).length.toString(),
        },
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return Response.internalServerError();
    }
  }

  Future<({dio_lib.Response<Uint8List> response, Uint8List? bytes})>
      streamTrack(
    SourcedTrack track,
    Map<String, dynamic> headers,
  ) async {
    final trackCacheFile = File(
      join(
        await UserPreferencesNotifier.getMusicCacheDir(),
        '${track.sourceInfo.title} - ${track.sourceInfo.artist} (${track.sourceInfo.id}).${track.codec.name}',
      ),
    );
    final trackPartialCacheFile = File("${trackCacheFile.path}.part");

    var options = Options(
      headers: {
        ...headers,
        "User-Agent":
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
        "Cache-Control": "max-age=0",
        "Connection": "keep-alive",
        "host": Uri.parse(track.url).host,
      },
      responseType: ResponseType.bytes,
      validateStatus: (status) => status! < 400,
    );

    final headersRes = await Future<dio_lib.Response?>.value(
      dio.head(
        track.url,
        options: options,
      ),
    ).catchError((_) async => null);

    final contentLength = headersRes?.headers.value("content-length");

    if (await trackCacheFile.exists() && userPreferences.cacheMusic) {
      final bytes = await trackCacheFile.readAsBytes();
      final cachedFileLength = bytes.length;

      return (
        response: dio_lib.Response<Uint8List>(
          statusCode: 200,
          headers: Headers.fromMap({
            "content-type": ["audio/${track.codec.name}"],
            "content-length": ["$cachedFileLength"],
            "accept-ranges": ["bytes"],
            "content-range": ["bytes 0-$cachedFileLength/$cachedFileLength"],
          }),
          requestOptions: RequestOptions(path: track.url),
        ),
        bytes: bytes,
      );
    }

    /// Forcing partial content range as mpv sometimes greedily wants
    /// everything at one go. Slows down overall streaming.
    final range = RangeHeader.parse(headers["range"] ?? "");
    final contentPartialLength = int.tryParse(contentLength ?? "");
    if ((range.end == null) &&
        contentPartialLength != null &&
        range.start == 0) {
      options = options.copyWith(
        headers: {
          ...?options.headers,
          "range": "$range${(contentPartialLength * 0.3).ceil()}",
        },
      );
    }

    final res = await dio.get<Uint8List>(track.url, options: options).catchError(
      (e, stack) async {
        final sourcedTrack = await ref
            .read(sourcedTrackProvider(SpotubeMedia(
              track,
   
            )).notifier)
            .switchToAlternativeSources();

        ref.read(activeSourcedTrackProvider.notifier).update(sourcedTrack);
        return await dio.get<Uint8List>(sourcedTrack!.url, options: options);
      },
    );

    final bytes = res.data;

    if (bytes == null || !userPreferences.cacheMusic) {
      return (response: res, bytes: bytes);
    }

    final contentRange =
        ContentRangeHeader.parse(res.headers.value("content-range") ?? "");

    if (!await trackPartialCacheFile.exists()) {
      await trackPartialCacheFile.create(recursive: true);
    }

    // Write the stream to the file based on the range
    final partialCacheFile =
        await trackPartialCacheFile.open(mode: FileMode.writeOnlyAppend);
    int fileLength = 0;
    try {
      await partialCacheFile.setPosition(contentRange.start);
      await partialCacheFile.writeFrom(bytes);
      fileLength = await partialCacheFile.length();
    } finally {
      await partialCacheFile.close();
    }

    if (fileLength == contentRange.total) {
      await trackPartialCacheFile.rename(trackCacheFile.path);
    }

    if (contentRange.total == fileLength && track.codec != SourceCodecs.weba) {
      final imageBytes = await ServiceUtils.downloadImage(
        track.sourceInfo.thumbnail,  // 使用 thumbnail 而不是 imageUrl
      );

      await MetadataGod.writeMetadata(
        file: trackCacheFile.path,
        metadata: Metadata(
          title: track.sourceInfo.title,
          artist: track.sourceInfo.artist,
          album: track.sourceInfo.album ?? '',  // album 可能为 null，提供默认值
          fileSize: BigInt.from(fileLength),
          picture: imageBytes != null 
              ? Picture(
                  mimeType: 'image/jpeg',
                  data: imageBytes,
                ) 
              : null,
        ),
      );
    }

    return (bytes: bytes, response: res);
  }

  /// @get('/stream/<trackId>')
  Future<Response> getStreamTrackId(Request request, String trackId) async {
    try {
      final track = playlist.tracks.firstWhere(
        (element) => element is LocalTrack 
            ? (element).path == trackId
            : element.id == trackId
      );

      if (track is LocalTrack) {
        final localTrack = track;
        final file = File(localTrack.path);
        if (!await file.exists()) {
          return Response.notFound('Track file not found');
        }
        return Response.ok(
          await file.readAsBytes(),
          headers: {
            'content-type': 'audio/mpeg',
          },
        );
      }

      final activeSourcedTrack = ref.read(activeSourcedTrackProvider);
      final sourcedTrack = activeSourcedTrack?.id == track.id
          ? activeSourcedTrack
          : await ref.read(sourcedTrackProvider(
              SpotubeMedia(
                track,
              ),
            ).future);

      ref.read(activeSourcedTrackProvider.notifier).update(sourcedTrack);

      // 添加对 HLS 播放列表的支持
      if (sourcedTrack!.url.contains(".m3u8")) {
        return await proxyHls(sourcedTrack.url, request.headers);
      }

      final (bytes: audioBytes, response: res) =
          await streamTrack(sourcedTrack, request.headers);

      return Response(
        res.statusCode!,
        body: audioBytes,
        headers: res.headers.map,
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return Response.internalServerError();
    }
  }
}

final serverPlaybackRoutesProvider =
    Provider((ref) => ServerPlaybackRoutes(ref));