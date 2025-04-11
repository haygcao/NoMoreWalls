import 'package:flutter/material.dart';
import '../services/music_service.dart';
import '../base/interfaces/media/track_interface.dart';
import '../base/interfaces/media/artist_interface.dart';
import '../base/interfaces/media/playlist_interface.dart';

class MusicProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService();

  // State variables
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ArtistInterface> get recommendedArtists =>
      _musicService.recommendedArtists;
  List<TrackInterface> get recentTracks => _musicService.recentTracks;
  List<PlaylistInterface> get featuredPlaylists =>
      _musicService.featuredPlaylists;

  // Initialize data
  Future<void> initializeData() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _musicService.fetchRecommendedArtists(),
        _musicService.fetchRecentTracks(),
        _musicService.fetchFeaturedPlaylists(),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Playback controls
  Future<void> playTrack(TrackInterface track) async {
    try {
      await _musicService.playTrack(track);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> pauseTrack() async {
    try {
      await _musicService.pauseTrack();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> stopTrack() async {
    try {
      await _musicService.stopTrack();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // User interactions
  Future<void> followArtist(ArtistInterface artist) async {
    try {
      await _musicService.followArtist(artist);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> likeTrack(TrackInterface track) async {
    try {
      await _musicService.likeTrack(track);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> followPlaylist(PlaylistInterface playlist) async {
    try {
      await _musicService.followPlaylist(playlist);
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
