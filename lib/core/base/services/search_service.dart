import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/media/track_interface.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/artist_interface.dart';
import '../interfaces/media/playlist_interface.dart';

/// Base class for search services
///
/// Provides methods for searching media across platforms
abstract class SearchService extends BaseService {
  /// Search for tracks matching the query
  Future<List<TrackInterface>> searchTracks(String query,
      {int limit = 20, int offset = 0});

  /// Search for albums matching the query
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int limit = 20, int offset = 0});

  /// Search for artists matching the query
  Future<List<ArtistInterface>> searchArtists(String query,
      {int limit = 20, int offset = 0});

  /// Search for playlists matching the query
  Future<List<PlaylistInterface>> searchPlaylists(String query,
      {int limit = 20, int offset = 0});

  /// Search across all media types
  Future<SearchResults> search(String query, {int limit = 20, int offset = 0});

  /// Search across all media types and return results as a map
  Future<Map<String, List<dynamic>>> searchAll(String query,
      {int limit = 20, int offset = 0});

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String partialQuery,
      {int limit = 5});
}

/// Container for search results across different media types
class SearchResults {
  /// List of tracks matching the search query
  final List<TrackInterface> tracks;

  /// List of albums matching the search query
  final List<AlbumInterface> albums;

  /// List of artists matching the search query
  final List<ArtistInterface> artists;

  /// List of playlists matching the search query
  final List<PlaylistInterface> playlists;

  /// Create a new search results container
  SearchResults({
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
  });
}
