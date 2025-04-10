import 'package:flutter/material.dart';
import '../base/interfaces/media/track_interface.dart';
import '../base/interfaces/media/artist_interface.dart';
import '../base/interfaces/media/playlist_interface.dart';

class SearchService extends ChangeNotifier {
  // Singleton instance
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  // Search state
  bool _isLoading = false;
  String _lastQuery = '';
  List<TrackInterface> _trackResults = [];
  List<ArtistInterface> _artistResults = [];
  List<PlaylistInterface> _playlistResults = [];

  // Getters
  bool get isLoading => _isLoading;
  String get lastQuery => _lastQuery;
  List<TrackInterface> get trackResults => _trackResults;
  List<ArtistInterface> get artistResults => _artistResults;
  List<PlaylistInterface> get playlistResults => _playlistResults;

  // Search methods
  Future<void> search(String query) async {
    if (query.isEmpty) return;

    try {
      _setLoading(true);
      _lastQuery = query;

      // TODO: Implement search API calls
      await Future.wait([
        searchTracks(query),
        searchArtists(query),
        searchPlaylists(query),
      ]);
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchTracks(String query) async {
    try {
      // TODO: Implement track search logic
      notifyListeners();
    } catch (e) {
      throw Exception('Track search failed: ${e.toString()}');
    }
  }

  Future<void> searchArtists(String query) async {
    try {
      // TODO: Implement artist search logic
      notifyListeners();
    } catch (e) {
      throw Exception('Artist search failed: ${e.toString()}');
    }
  }

  Future<void> searchPlaylists(String query) async {
    try {
      // TODO: Implement playlist search logic
      notifyListeners();
    } catch (e) {
      throw Exception('Playlist search failed: ${e.toString()}');
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearResults() {
    _trackResults.clear();
    _artistResults.clear();
    _playlistResults.clear();
    _lastQuery = '';
    notifyListeners();
  }
}
