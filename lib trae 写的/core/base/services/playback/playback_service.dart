import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// Enum defining possible playback states
enum PlaybackState {
  /// No track is loaded
  idle,

  /// Track is loaded but not playing
  paused,

  /// Track is currently playing
  playing,

  /// Track is currently buffering
  buffering,

  /// Playback encountered an error
  error
}

/// Abstract class defining the interface for playback services
abstract class PlaybackService {
  /// Current playback state
  PlaybackState get state;

  /// Currently playing track
  TrackInterface? get currentTrack;

  /// Current playback position in milliseconds
  int get position;

  /// Current playback volume (0.0 to 1.0)
  double get volume;

  /// Whether playback is currently muted
  bool get isMuted;

  /// Load a track for playback
  Future<void> load(TrackInterface track);

  /// Start or resume playback
  Future<void> play();

  /// Pause playback
  Future<void> pause();

  /// Stop playback and unload current track
  Future<void> stop();

  /// Seek to position in milliseconds
  Future<void> seek(int position);

  /// Set playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Toggle mute state
  Future<void> toggleMute();

  /// Clean up resources
  Future<void> dispose();
}

/// Provider for the playback service
final playbackServiceProvider = Provider<PlaybackService>((ref) {
  throw UnimplementedError(
      'No PlaybackService implementation has been provided');
});
