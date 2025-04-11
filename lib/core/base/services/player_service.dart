import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/player/player_interface.dart';
import '../interfaces/player/queue_interface.dart';
import '../interfaces/player/playback_interface.dart';

/// Base class for player services
///
/// Provides methods for controlling playback across platforms
abstract class PlayerService extends BaseService
    implements PlayerInterface, QueueInterface {
  /// Get the playback interface for this player
  PlaybackInterface get playback;

  /// Get the current track ID
  String? get currentTrackId;

  /// Get the current playback position
  Duration get position;

  /// Get the current buffered position
  Duration get bufferedPosition;

  /// Get the total duration of the current track
  Duration get duration;

  /// Get the current volume level (0.0 to 1.0)
  double get volume;

  /// Get the current playback state
  PlaybackState get state;

  /// Get the current repeat mode
  RepeatMode get repeatMode;

  /// Get the current shuffle mode
  bool get shuffleMode;

  /// Play a track or album/playlist
  ///
  /// If trackId is provided, plays that specific track
  /// If sourceId is provided, loads that album/playlist and starts playing
  @override
  Future<void> play(
      {required String trackId, String? sourceId, String? sourceName});

  /// Connect to remote devices (if supported)
  Future<List<String>> getAvailableDevices();

  /// Transfer playback to another device (if supported)
  Future<bool> transferPlayback(String deviceId);

  /// Add a track to the queue
  Future<void> addToQueue(String trackId);

  /// Remove a track from the queue by its position
  Future<void> removeFromQueue(int index);

  /// Clear the queue
  @override
  Future<void> clearQueue();
}
