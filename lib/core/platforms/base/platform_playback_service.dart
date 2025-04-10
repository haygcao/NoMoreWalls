import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/services/playback/playback_service.dart';

/// Abstract base class for platform-specific playback implementations
abstract class PlatformPlaybackService extends PlaybackService {
  PlaybackState _state = PlaybackState.idle;
  TrackInterface? _currentTrack;
  int _position = 0;
  double _volume = 1.0;
  bool _isMuted = false;

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

  /// Platform-specific implementation for loading a track
  @protected
  Future<void> platformLoad(TrackInterface track);

  /// Platform-specific implementation for starting playback
  @protected
  Future<void> platformPlay();

  /// Platform-specific implementation for pausing playback
  @protected
  Future<void> platformPause();

  /// Platform-specific implementation for stopping playback
  @protected
  Future<void> platformStop();

  /// Platform-specific implementation for seeking
  @protected
  Future<void> platformSeek(int position);

  /// Platform-specific implementation for setting volume
  @protected
  Future<void> platformSetVolume(double volume);

  /// Platform-specific implementation for cleanup
  @protected
  Future<void> platformDispose();

  @override
  Future<void> load(TrackInterface track) async {
    try {
      _state = PlaybackState.buffering;
      await platformLoad(track);
      _currentTrack = track;
      _state = PlaybackState.paused;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    if (_currentTrack == null) {
      throw StateError('No track is loaded');
    }
    try {
      await platformPlay();
      _state = PlaybackState.playing;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    if (_state != PlaybackState.playing) return;
    try {
      await platformPause();
      _state = PlaybackState.paused;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_state == PlaybackState.idle) return;
    try {
      await platformStop();
      _state = PlaybackState.idle;
      _currentTrack = null;
      _position = 0;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> seek(int position) async {
    if (_currentTrack == null) return;
    try {
      await platformSeek(position);
      _position = position;
    } catch (e) {
      _state = PlaybackState.error;
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await platformSetVolume(volume);
      _volume = volume;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> toggleMute() async {
    try {
      final newVolume = _isMuted ? _volume : 0.0;
      await platformSetVolume(newVolume);
      _isMuted = !_isMuted;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await platformDispose();
      _state = PlaybackState.idle;
      _currentTrack = null;
      _position = 0;
    } catch (e) {
      rethrow;
    }
  }
}
