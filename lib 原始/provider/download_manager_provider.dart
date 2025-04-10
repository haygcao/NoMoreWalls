import 'dart:async';
import 'dart:io';


import 'package:spotube/services/logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart';
// 移除 spotify 导入
// import 'package:spotify/spotify.dart';
// 添加新的导入
import 'package:spotube/services/base/sourceable_track.dart';


import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/services/download_manager/download_manager.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:spotube/utils/primitive_utils.dart';
import 'package:spotube/utils/service_utils.dart';

// 添加 Metadata 扩展方法
// Add this import for Uint8List

extension SourcedTrackMetadataExtension on SourcedTrack {
  Metadata toMetadata({
    required BigInt? fileLength,
    required Uint8List? imageBytes,
  }) {
    return Metadata(
      title: track.title,
      artist: track.artistName,
      album: track.albumName,
      fileSize: fileLength,
      picture: imageBytes != null ? Picture(data: imageBytes, mimeType: "image/jpeg") : null,
    );
  }
}

class DownloadManagerProvider extends ChangeNotifier {
  DownloadManagerProvider({required this.ref})
      : $history = <SourcedTrack>{},
        $backHistory = <SourceableTrack>{},
        dl = DownloadManager() {
    dl.statusStream.listen((event) async {
      try {
        final (:request, :status) = event;

        final track = $history.firstWhereOrNull(
          (element) => element.getUrlOfCodec(downloadCodec) == request.url,
        );
        if (track == null) return;

        final savePath = getTrackFileUrl(track);
        // related to onFileExists
        final oldFile = File("$savePath.old");

        // if download failed and old file exists, rename it back
        if ((status == DownloadStatus.failed ||
                status == DownloadStatus.canceled) &&
            await oldFile.exists()) {
          await oldFile.rename(savePath);
        }
        if (status != DownloadStatus.completed ||
            //? WebA audiotagging is not supported yet
            //? Although in future by converting weba to opus & then tagging it
            //? is possible using vorbis comments
            downloadCodec == SourceCodecs.weba) return;

        final file = File(request.path);

        if (await oldFile.exists()) {
          await oldFile.delete();
        }

        // 使用 thumbnailUrl 替代 album.images
        final imageBytes = await ServiceUtils.downloadImage(
          track.track.thumbnailUrl ?? "",
        );

        final metadata = track.toMetadata(
          fileLength: BigInt.from(await file.length()),
          imageBytes: imageBytes != null ? Uint8List.fromList(imageBytes) : null,
        );

        await MetadataGod.writeMetadata(
          file: file.path,
          metadata: metadata,
        );
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });
  }

  Future<bool> Function(SourceableTrack track) onFileExists = (SourceableTrack track) async => true;

  final Ref<DownloadManagerProvider> ref;

  String get downloadDirectory =>
      ref.read(userPreferencesProvider.select((s) => s.downloadLocation));
  SourceCodecs get downloadCodec =>
      ref.read(userPreferencesProvider.select((s) => s.downloadMusicCodec));

  int get $downloadCount => dl
      .getAllDownloads()
      .where(
        (download) =>
            download.status.value == DownloadStatus.downloading ||
            download.status.value == DownloadStatus.paused ||
            download.status.value == DownloadStatus.queued,
      )
      .length;

  final Set<SourcedTrack> $history;
  final Set<SourceableTrack> $backHistory;
  final DownloadManager dl;

  String getTrackFileUrl(SourceableTrack track) {
    final name =
        "${track.title} - ${track.artistName}.${downloadCodec.name}";
    return join(downloadDirectory, PrimitiveUtils.toSafeFileName(name));
  }

  // 修改参数类型
  bool isActive(SourceableTrack track) {
    if ($backHistory.contains(track)) return true;

    final sourcedTrack = mapToSourcedTrack(track);

    if (sourcedTrack == null) return false;

    return dl
        .getAllDownloads()
        .where(
          (download) =>
              download.status.value == DownloadStatus.downloading ||
              download.status.value == DownloadStatus.paused ||
              download.status.value == DownloadStatus.queued,
        )
        .map((e) => e.request.url)
        .contains(sourcedTrack.getUrlOfCodec(downloadCodec));
  }

  // 修改参数类型
  Future<void> addToQueue(SourceableTrack track) async {
    final savePath = getTrackFileUrl(track);

    final oldFile = File(savePath);
    if (await oldFile.exists() && !await onFileExists(track)) {
      return;
    }

    if (await oldFile.exists()) {
      await oldFile.rename("$savePath.old");
    }

    if (track is SourcedTrack && track.codec == downloadCodec) {
      final downloadTask =
          await dl.addDownload(track.getUrlOfCodec(downloadCodec), savePath);
      if (downloadTask != null) {
        $history.add(track);
      }
    } else {
      $backHistory.add(track);
      final sourcedTrack = await SourcedTrack.fetchFromTrack(
        track: track,
      ).then((d) {
        $backHistory.remove(track);
        return d;
      });
      final downloadTask = await dl.addDownload(
        sourcedTrack.getUrlOfCodec(downloadCodec),
        savePath,
      );
      if (downloadTask != null) {
        $history.add(sourcedTrack);
      }
    }

    notifyListeners();
  }

  // 修改参数类型
  Future<void> batchAddToQueue(List<SourceableTrack> tracks) async {
    $backHistory.addAll(
      tracks.where((element) => element is! SourcedTrack),
    );
    notifyListeners();
    for (final track in tracks) {
      try {
        if (track == tracks.first) {
          await addToQueue(track);
        } else {
          await Future.delayed(
            const Duration(seconds: 1),
            () => addToQueue(track),
          );
        }
      } catch (e) {
        AppLogger.reportError(e, StackTrace.current);
        continue;
      }
    }
  }

  // 修改参数和返回类型
  SourcedTrack? mapToSourcedTrack(SourceableTrack track) {
    if (track is SourcedTrack) {
      return track;
    } else {
      return $history.firstWhereOrNull((element) => element.id == track.id);
    }
  }

  Future<void> removeFromQueue(SourcedTrack track) async {
    await dl.removeDownload(track.getUrlOfCodec(downloadCodec));
    $history.remove(track);
  }

  Future<void> pause(SourcedTrack track) {
    return dl.pauseDownload(track.getUrlOfCodec(downloadCodec));
  }

  Future<void> resume(SourcedTrack track) {
    return dl.resumeDownload(track.getUrlOfCodec(downloadCodec));
  }

  Future<void> retry(SourcedTrack track) {
    return addToQueue(track);
  }

  void cancel(SourcedTrack track) {
    dl.cancelDownload(track.getUrlOfCodec(downloadCodec));
  }

  void cancelAll() {
    for (final download in dl.getAllDownloads()) {
      if (download.status.value == DownloadStatus.completed) continue;
      dl.cancelDownload(download.request.url);
    }
  }



  ValueNotifier<DownloadStatus>? getStatusNotifier(SourcedTrack track) {
    return dl.getDownload(track.getUrlOfCodec(downloadCodec))?.status;
  }

  ValueNotifier<double>? getProgressNotifier(SourcedTrack track) {
    return dl.getDownload(track.getUrlOfCodec(downloadCodec))?.progress;
  }
}

final downloadManagerProvider = ChangeNotifierProvider<DownloadManagerProvider>(
  (ref) => DownloadManagerProvider(ref: ref),
);
