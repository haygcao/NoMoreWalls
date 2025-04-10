import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/services/playback/playback_service.dart';

/// PlaybackManager coordinates multiple playback service implementations
/// to provide unified playback functionality across different platforms
class PlaybackManager extends PlaybackService {
  final List<PlaybackService> _playbackServices;
  final bool _fallbackEnabled;
  PlaybackService? _activeService;

  PlaybackState _state = PlaybackState.idle;
  TrackInterface? _currentTrack;
  int _position = 0;
  double _volume = 1.0;
  bool _isMuted = false;

  PlaybackManager(this._playbackServices, {bool fallbackEnabled = true})
      : _fallbackEnabled = fallbackEnabled,
        assert(_playbackServices.isNotEmpty,
            'At least one playback service must be provided');

  @override
  PlaybackState get state => _state;

  @override
  TrackInterface? get currentTrack => _currentTrack;

  @override
  int get position => _position;

  @override
  double get volume => _volume;

  @override
  bool get isMuted => _isMuted;

  @override
  Future<void> load(TrackInterface track) async {
    _currentTrack = track;
    for (var i = 0; i < _playbackServices.length; i++) {
      try {
        await _playbackServices[i].load(track);
        _activeService = _playbackServices[i];
        _state = PlaybackState.paused;
        return;
      } catch (e) {
        if (!_fallbackEnabled || i == _playbackServices.length - 1) {
          _state = PlaybackState.error;
          rethrow;
        }
      }
    }
  }

  @override
  Future<void> play() async {
    if (_activeService == null) {
      throw StateError('No track is loaded');
    }
    try {
      await _activeService!.play();
      _state = PlaybackState.playing;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    if (_activeService == null) return;
    try {
      await _activeService!.pause();
      _state = PlaybackState.paused;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_activeService == null) return;
    try {
      await _activeService!.stop();
      _state = PlaybackState.idle;
      _currentTrack = null;
      _position = 0;
      _activeService = null;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> seek(int position) async {
    if (_activeService == null) return;
    try {
      await _activeService!.seek(position);
      _position = position;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_activeService == null) return;
    try {
      await _activeService!.setVolume(volume);
      _volume = volume;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> toggleMute() async {
    if (_activeService == null) return;
    try {
      await _activeService!.toggleMute();
      _isMuted = !_isMuted;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (_activeService != null) {
      await _activeService!.dispose();
      _activeService = null;
    }
    _state = PlaybackState.idle;
    _currentTrack = null;
    _position = 0;
  }
}

/// Provider for the PlaybackManager
final playbackManagerProvider = Provider<PlaybackManager>((ref) {
  throw UnimplementedError(
      'No PlaybackManager implementation has been provided');
});
