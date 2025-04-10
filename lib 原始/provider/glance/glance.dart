import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/server/server.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/logger/logger.dart';
import 'package:spotube/utils/platform.dart';

import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/sourced_track.dart';

@pragma("vm:entry-point")
Future<void> glanceBackgroundCallback(Uri? data) async {
  final logger = Logger();
  try {
    if (data == null ||
        data.host != "playback" ||
        data.pathSegments.isEmpty ||
        data.queryParameters["serverAddress"] == null) {
      return;
    }

    final command = data.pathSegments.first;
    final res = await get(
      Uri.parse(
        "http://${data.queryParameters["serverAddress"]}/playback/$command",
      ),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to execute command: $command\nBody: ${res.body}");
    }
  } catch (e) {
    logger.e("[GlanceBackgroundCallback] $e");
  }
}

Future<bool?> _saveWidgetData<T>(String key, T? value) async {
  try {
    if (!kIsMobile) return null;

    return await HomeWidget.saveWidgetData<T>(key, value);
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return null;
  }
}

Future<void> _updateWidget() async {
  try {
    if (!kIsMobile) return;

    if (kIsAndroid) {
      await HomeWidget.updateWidget(
        androidName: 'HomePlayerWidgetReceiver',
        qualifiedAndroidName:
            'oss.krtirtho.spotube.glance.HomePlayerWidgetReceiver',
      );
    }
    if (kIsIOS) {
      await HomeWidget.updateWidget(
        name: 'HomePlayerWidget',
        iOSName: 'HomePlayerWidget',
      );
    }
  } on Exception catch (e, stack) {
    AppLogger.reportError(e, stack);
  }
}

// 修改 _sendActiveTrack 方法，使用 BaseTrack 接口
Future<void> _sendActiveTrack(BaseTrack? track) async {
  if (track == null) {
    await _saveWidgetData("activeTrack", null);
    await _updateWidget();
    return;
  }

  final jsonTrack = track.toJson();
  
  // 处理专辑图片，需要根据不同类型的 track 进行适配
  String? imagePath;
  
  if (track is SourceableTrack && track.thumbnailUrl != null) {
    final cachedImage = await DefaultCacheManager().getSingleFile(track.thumbnailUrl!);
    imagePath = cachedImage.path;
  }
  
  final data = {
    ...jsonTrack,
    "thumbnailPath": imagePath,
  };

  await _saveWidgetData("activeTrack", jsonEncode(data));
  await _updateWidget();
}

final glanceProvider = Provider((ref) {
  final server = ref.read(serverProvider);
  final activeTrack = ref.read(audioPlayerProvider).activeTrack;

  server.whenData(
    (value) async {
      final (:server, :port) = value;

      await _saveWidgetData(
        "playbackServerAddress",
        "${server.address.host}:$port",
      );
      await _updateWidget();
    },
  );

  // 确保类型兼容
  if (activeTrack is BaseTrack) {
    _sendActiveTrack(activeTrack);
  }

  ref.listen(serverProvider, (prev, next) async {
    next.whenData(
      (value) async {
        final (:server, :port) = value;

        await _saveWidgetData(
          "playbackServerAddress",
          "${server.address.host}:$port",
        );
        await _updateWidget();
      },
    );
  });

  ref.listen(
    audioPlayerProvider,
    (previous, next) async {
      try {
        if (previous?.activeTrack != next.activeTrack &&
            next.activeTrack != null && 
            next.activeTrack is BaseTrack) {
          await _sendActiveTrack(next.activeTrack as BaseTrack);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    },
  );

  final subscriptions = [
    audioPlayer.playingStream.listen((playing) async {
      await _saveWidgetData("isPlaying", playing);
      await _updateWidget();
    }),
    audioPlayer.positionStream.listen((position) async {
      await _saveWidgetData("position", position.inSeconds);
      await _updateWidget();
    }),
    audioPlayer.durationStream.listen((duration) async {
      await _saveWidgetData("duration", duration.inSeconds);
      await _updateWidget();
    }),
  ];

  ref.onDispose(() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  });
});