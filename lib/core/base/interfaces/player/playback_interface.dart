import 'package:flutter/foundation.dart';
import 'player_interface.dart';

/// Interface for playback state and control
///
/// Defines the methods and properties for monitoring and controlling playback state
@immutable
abstract class PlaybackInterface {
  /// Stream of playback positions
  Stream<Duration> get positionStream;

  /// Stream of buffered positions
  Stream<Duration> get bufferedPositionStream;

  /// Stream of total durations
  Stream<Duration> get durationStream;

  /// Stream of playback states (playing, paused, etc.)
  Stream<PlaybackState> get playbackStateStream;

  /// Stream of current track IDs
  Stream<String?> get currentTrackStream;

  /// Stream of volume changes
  Stream<double> get volumeStream;

  /// Stream of repeat mode changes
  Stream<RepeatMode> get repeatModeStream;

  /// Stream of shuffle mode changes
  Stream<bool> get shuffleModeStream;

  /// Get the current playback state
  PlaybackState get currentState;

  /// Get the current volume level
  double get volume;

  /// Get the current repeat mode
  RepeatMode get repeatMode;

  /// Get the current shuffle mode
  bool get shuffleMode;
}

/// Enum representing the current state of playback
enum PlaybackState {
  /// No track is loaded
  none,

  /// Track is loaded but not playing
  paused,

  /// Track is currently playing
  playing,

  /// Track is being loaded/buffered
  buffering,

  /// Playback has completed
  completed,

  /// An error occurred during playback
  error
}
