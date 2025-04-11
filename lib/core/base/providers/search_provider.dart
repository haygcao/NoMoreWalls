import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_service.dart';
import '../interfaces/media/track_interface.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/artist_interface.dart';
import '../interfaces/media/playlist_interface.dart';
import 'base_provider.dart';

/// Provider for search services
///
/// Manages state and operations related to searching media content
abstract class SearchProvider extends BaseProvider<SearchService> {
  /// Create a new search provider
  SearchProvider() : super();

  /// Search for tracks matching the query
  Future<AsyncValue<List<TrackInterface>>> searchTracks(String query,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.searchTracks(query, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Search for albums matching the query
  Future<AsyncValue<List<AlbumInterface>>> searchAlbums(String query,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.searchAlbums(query, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Search for artists matching the query
  Future<AsyncValue<List<ArtistInterface>>> searchArtists(String query,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.searchArtists(query, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Search for playlists matching the query
  Future<AsyncValue<List<PlaylistInterface>>> searchPlaylists(String query,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.searchPlaylists(query, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Search for all media types matching the query
  Future<AsyncValue<Map<String, List<dynamic>>>> searchAll(String query,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.searchAll(query, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get search suggestions based on partial query
  Future<AsyncValue<List<String>>> getSearchSuggestions(
      String partialQuery) async {
    try {
      final suggestions = await service.getSearchSuggestions(partialQuery);
      return AsyncValue.data(suggestions);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }
}
