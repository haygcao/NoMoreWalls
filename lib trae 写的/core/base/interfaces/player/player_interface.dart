import '../media/track_interface.dart';

/// Interface defining the core player functionality
abstract class PlayerInterface {
  /// Current playing track
  TrackInterface? get currentTrack;

  /// Current playback position in milliseconds
  int get position;

  /// Total duration of current track in milliseconds
  int get duration;

  /// Current playback state
  PlayerState get state;

  /// Current volume level (0.0 to 1.0)
  double get volume;

  /// Whether audio is currently muted
  bool get isMuted;

  /// Whether player is currently shuffling
  bool get isShuffling;

  /// Current repeat mode
  RepeatMode get repeatMode;

  /// Play the specified track
  Future<void> play(TrackInterface track);

  /// Resume playback
  Future<void> resume();

  /// Pause playback
  Future<void> pause();

  /// Stop playback
  Future<void> stop();

  /// Seek to position
  Future<void> seek(int position);

  /// Skip to next track
  Future<void> next();

  /// Skip to previous track
  Future<void> previous();

  /// Set volume level
  Future<void> setVolume(double volume);

  /// Toggle mute state
  Future<void> toggleMute();

  /// Toggle shuffle mode
  Future<void> toggleShuffle();

  /// Set repeat mode
  Future<void> setRepeatMode(RepeatMode mode);

  /// Stream of player state changes
  Stream<PlayerState> get onPlayerStateChanged;

  /// Stream of position updates
  Stream<int> get onPositionChanged;

  /// Stream of current track changes
  Stream<TrackInterface?> get onTrackChanged;
}

/// Enum defining possible player states
enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}

/// Enum defining repeat modes
enum RepeatMode {
  off,
  track,
  playlist,
}
