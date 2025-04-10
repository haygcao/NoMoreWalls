import '../media/track_interface.dart';
import 'player_interface.dart';

/// Interface defining playback event callbacks and state management
abstract class PlaybackInterface {
  /// Called when playback state changes
  void onPlaybackStateChanged(PlayerState state);

  /// Called when current track changes
  void onTrackChanged(TrackInterface? track);

  /// Called when playback position changes
  void onPositionChanged(int position);

  /// Called when playback encounters an error
  void onPlaybackError(String message);

  /// Called when buffering state changes
  void onBufferingStateChanged(bool isBuffering);

  /// Called when volume changes
  void onVolumeChanged(double volume);

  /// Called when mute state changes
  void onMuteStateChanged(bool isMuted);

  /// Called when shuffle mode changes
  void onShuffleModeChanged(bool isShuffling);

  /// Called when repeat mode changes
  void onRepeatModeChanged(RepeatMode mode);

  /// Called when audio session is activated
  void onAudioSessionActivated();

  /// Called when audio session is deactivated
  void onAudioSessionDeactivated();

  /// Called when audio focus is gained
  void onAudioFocusGained();

  /// Called when audio focus is lost
  void onAudioFocusLost();

  /// Called when metadata changes
  void onMetadataChanged(Map<String, dynamic> metadata);

  /// Called when playback quality changes
  void onPlaybackQualityChanged(String quality);

  /// Called when network state changes
  void onNetworkStateChanged(bool isConnected);
}
