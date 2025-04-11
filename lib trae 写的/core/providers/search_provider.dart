import 'package:flutter/material.dart';
import '../base/services/search/search_service.dart';
import '../base/interfaces/media/track_interface.dart';
import '../base/interfaces/media/artist_interface.dart';
import '../base/interfaces/media/playlist_interface.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  // State
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastQuery => _searchService.lastQuery;
  List<TrackInterface> get trackResults => _searchService.trackResults;
  List<ArtistInterface> get artistResults => _searchService.artistResults;
  List<PlaylistInterface> get playlistResults => _searchService.playlistResults;

  // Search methods
  Future<void> search(String query) async {
    if (query.isEmpty) return;

    _setLoading(true);
    _clearError();

    try {
      await _searchService.search(query);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchTracks(String query) async {
    _clearError();

    try {
      await _searchService.searchTracks(query);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> searchArtists(String query) async {
    _clearError();

    try {
      await _searchService.searchArtists(query);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> searchPlaylists(String query) async {
    _clearError();

    try {
      await _searchService.searchPlaylists(query);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearResults() {
    _clearError();
    _searchService.clearResults();
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
