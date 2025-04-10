import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/services/search_service.dart';
import 'package:spotube/core/base/services/service_registry.dart';

/// SearchManager is responsible for managing multiple search service implementations
/// and coordinating searches across them. This ensures the core search functionality
/// is completely platform-independent.
class SearchManager extends SearchService {
  final List<SearchService> _searchServices;
  final bool _fallbackEnabled;

  SearchManager(Map<String, SearchService> services,
      {bool fallbackEnabled = true})
      : _searchServices = services.values.toList(),
        _fallbackEnabled = fallbackEnabled,
        assert(services.isNotEmpty,
            'At least one search service must be provided');

  @override
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset}) async {
    for (var i = 0; i < _searchServices.length; i++) {
      try {
        final results = await _searchServices[i]
            .searchTracks(query, limit: limit, offset: offset);
        if (results.isNotEmpty) return results;
      } catch (e) {
        if (!_fallbackEnabled || i == _searchServices.length - 1) rethrow;
      }
    }
    return [];
  }

  @override
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset}) async {
    for (var i = 0; i < _searchServices.length; i++) {
      try {
        final results = await _searchServices[i]
            .searchAlbums(query, limit: limit, offset: offset);
        if (results.isNotEmpty) return results;
      } catch (e) {
        if (!_fallbackEnabled || i == _searchServices.length - 1) rethrow;
      }
    }
    return [];
  }

  @override
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset}) async {
    for (var i = 0; i < _searchServices.length; i++) {
      try {
        final results = await _searchServices[i]
            .searchArtists(query, limit: limit, offset: offset);
        if (results.isNotEmpty) return results;
      } catch (e) {
        if (!_fallbackEnabled || i == _searchServices.length - 1) rethrow;
      }
    }
    return [];
  }
}

/// Provider for the search service registry
final searchServiceRegistryProvider =
    createServiceRegistryProvider<SearchService>();

/// Provider that creates a SearchManager instance using registered search services
final searchManagerProvider = Provider<SearchService>((ref) {
  final registry = ref.watch(searchServiceRegistryProvider);
  return SearchManager(registry.services);
});
