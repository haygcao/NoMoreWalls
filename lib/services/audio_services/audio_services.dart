import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/audio_services/mobile_audio_service.dart';
import 'package:spotube/services/audio_services/windows_audio_service.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/utils/platform.dart';

class AudioServices with WidgetsBindingObserver {
  final MobileAudioService? mobile;
  final WindowsAudioService? smtc;

  AudioServices(this.mobile, this.smtc) {
    WidgetsBinding.instance.addObserver(this);
  }

  static Future<AudioServices> create(
    Ref ref,
    AudioPlayerNotifier playback,
  ) async {
    final mobile = kIsMobile || kIsMacOS || kIsLinux
        ? await AudioService.init(
            builder: () => MobileAudioService(playback),
            config: AudioServiceConfig(
              androidNotificationChannelId:
                  kIsLinux ? 'spotube' : 'com.krtirtho.Spotube',
              androidNotificationChannelName: 'Spotube',
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: false,
              androidNotificationIcon: "drawable/ic_launcher_monochrome",
              androidNotificationChannelDescription: "Spotube Media Controls",
            ),
          )
        : null;
    final smtc = kIsWindows ? WindowsAudioService(ref, playback) : null;

    return AudioServices(mobile, smtc);
  }

  Future<void> addTrack(SourceableTrack track) async {
    await smtc?.addTrack(track);
    mobile?.addItem(MediaItem(
      id: track.id,
      album: track.albumName ?? "",
      title: track.title,
      artist: track.artistName,
      duration: track.duration,
      artUri: Uri.parse(track.thumbnailUrl ?? ""),
      playable: true,
    ));
  }

  void activateSession() {
    mobile?.session?.setActive(true);
  }

  void deactivateSession() {
    mobile?.session?.setActive(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        deactivateSession();
        audioPlayer.pause();
        break;
      default:
        break;
    }
  }

  void dispose() {
    smtc?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}