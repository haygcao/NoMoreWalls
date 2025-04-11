import 'package:flutter/material.dart';
import '../services/playback_service.dart';
import '../base/interfaces/media/track_interface.dart';

class PlaybackProvider extends ChangeNotifier {
  final PlaybackService _playbackService = PlaybackService();

  // State
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _playbackService.isPlaying;
  double get volume => _playbackService.volume;
  double get progress => _playbackService.progress;
  TrackInterface? get currentTrack => _playbackService.currentTrack;
  Duration get position => _playbackService.position;
  Duration get duration => _playbackService.duration;

  // Playback controls
  Future<void> play(TrackInterface track) async {
    _setLoading(true);
    _clearError();

    try {
      await _playbackService.play(track);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pause() async {
    _clearError();

    try {
      await _playbackService.pause();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> resume() async {
    _clearError();

    try {
      await _playbackService.resume();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> stop() async {
    _clearError();

    try {
      await _playbackService.stop();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Volume control
  void setVolume(double value) {
    _clearError();

    try {
      _playbackService.setVolume(value);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Progress control
  Future<void> seekTo(Duration position) async {
    _clearError();

    try {
      await _playbackService.seekTo(position);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
