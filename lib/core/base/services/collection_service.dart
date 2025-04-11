import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/media/collection_interface.dart';
import '../interfaces/media/track_interface.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/artist_interface.dart';
import '../interfaces/media/playlist_interface.dart';

/// Base class for collection services
///
/// Provides methods for retrieving and managing collections across platforms
abstract class CollectionService extends BaseService {
  /// Get featured collections
  Future<List<CollectionInterface>> getFeaturedCollections(
      {int limit = 20, int offset = 0});

  /// Get a collection by ID
  Future<CollectionInterface?> getCollection(String collectionId);

  /// Get tracks in a collection
  Future<List<TrackInterface>> getCollectionTracks(String collectionId,
      {int limit = 50, int offset = 0});

  /// Get albums in a collection
  Future<List<AlbumInterface>> getCollectionAlbums(String collectionId,
      {int limit = 20, int offset = 0});

  /// Get artists in a collection
  Future<List<ArtistInterface>> getCollectionArtists(String collectionId,
      {int limit = 20, int offset = 0});

  /// Get playlists in a collection
  Future<List<PlaylistInterface>> getCollectionPlaylists(String collectionId,
      {int limit = 20, int offset = 0});

  /// Get collections by category
  Future<List<CollectionInterface>> getCollectionsByCategory(String categoryId,
      {int limit = 20, int offset = 0});

  /// Get available categories
  Future<List<String>> getAvailableCategories();
}
