import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/player_service.dart';
import '../interfaces/player/playback_interface.dart';
import '../interfaces/player/player_interface.dart';
import 'base_provider.dart';

/// Provider for player services
///
/// Manages state and operations related to media playback
abstract class PlayerProvider extends BaseProvider<PlayerService> {
  /// Create a new player provider
  PlayerProvider() : super();

  /// Get the current track ID
  String? get currentTrackId => service.currentTrackId;

  /// Get the current playback position
  Duration get position => service.position;

  /// Get the current buffered position
  Duration get bufferedPosition => service.bufferedPosition;

  /// Get the total duration of the current track
  Duration get duration => service.duration;

  /// Get the current volume level (0.0 to 1.0)
  double get volume => service.volume;

  /// Get the current playback state
  PlaybackState get playbackState => service.state;

  /// Get the current repeat mode
  RepeatMode get repeatMode => service.repeatMode;

  /// Get the current shuffle mode
  bool get shuffleMode => service.shuffleMode;

  /// Play a track or album/playlist
  Future<void> play({
    required String trackId,
    String? sourceId,
    String? sourceName,
  }) async {
    await service.play(
      trackId: trackId,
      sourceId: sourceId,
      sourceName: sourceName,
    );
  }

  /// Pause the current playback
  Future<void> pause() async {
    await service.pause();
  }

  /// Resume playback of the current track
  Future<void> resume() async {
    await service.resume();
  }

  /// Stop the current playback
  Future<void> stop() async {
    await service.stop();
  }

  /// Seek to a specific position in the current track
  Future<void> seekTo(Duration position) async {
    await service.seekTo(position);
  }

  /// Skip to the next track
  Future<void> next() async {
    await service.next();
  }

  /// Skip to the previous track
  Future<void> previous() async {
    await service.previous();
  }

  /// Set the volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await service.setVolume(volume);
  }

  /// Set the repeat mode
  Future<void> setRepeatMode(RepeatMode mode) async {
    await service.setRepeatMode(mode);
  }

  /// Set the shuffle mode
  Future<void> setShuffleMode(bool enabled) async {
    await service.setShuffleMode(enabled);
  }

  /// Add a track to the queue
  Future<void> addToQueue(String trackId) async {
    await service.addToQueue(trackId);
  }

  /// Remove a track from the queue
  Future<void> removeFromQueue(int index) async {
    await service.removeFromQueue(index);
  }

  /// Get the current queue
  Future<AsyncValue<List<String>>> getQueue() async {
    try {
      final queue = await service.getQueue();
      return AsyncValue.data(queue);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Clear the queue
  Future<void> clearQueue() async {
    await service.clearQueue();
  }

  /// Connect to remote devices (if supported)
  Future<AsyncValue<List<String>>> getAvailableDevices() async {
    try {
      final devices = await service.getAvailableDevices();
      return AsyncValue.data(devices);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Transfer playback to another device (if supported)
  Future<void> transferPlayback(String deviceId) async {
    await service.transferPlayback(deviceId);
  }
}
