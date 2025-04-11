import 'package:flutter/foundation.dart';

/// Interface for player functionality
///
/// Defines the core methods and properties that any player implementation must provide
@immutable
abstract class PlayerInterface {
  /// Initialize the player
  Future<void> initialize();

  /// Play a track by its ID
  Future<void> play(
      {required String trackId, String? sourceId, String? sourceName});

  /// Pause the current playback
  Future<void> pause();

  /// Resume playback of the current track
  Future<void> resume();

  /// Stop the current playback
  Future<void> stop();

  /// Seek to a specific position in the current track
  Future<void> seekTo(Duration position);

  /// Skip to the next track
  Future<void> next();

  /// Skip to the previous track
  Future<void> previous();

  /// Set the volume level (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Get the current playback position
  Future<Duration> getPosition();

  /// Get the total duration of the current track
  Future<Duration> getDuration();

  /// Check if the player is currently playing
  Future<bool> isPlaying();

  /// Dispose the player and release resources
  Future<void> dispose();

  /// Get the current track ID
  Future<String?> getCurrentTrackId();

  /// Set the playback speed (1.0 is normal speed)
  Future<void> setPlaybackSpeed(double speed);

  /// Set whether to repeat the current track
  Future<void> setRepeatMode(RepeatMode mode);

  /// Set whether to shuffle the playlist
  Future<void> setShuffleMode(bool enabled);
}

/// Enum representing repeat modes for playback
enum RepeatMode {
  /// No repeat
  off,

  /// Repeat the current track
  one,

  /// Repeat the entire playlist/album
  all
}
