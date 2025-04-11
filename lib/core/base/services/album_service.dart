import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/track_interface.dart';

/// Base class for album services
///
/// Provides methods for retrieving album information across platforms
abstract class AlbumService extends BaseService {
  /// Get an album by ID
  Future<AlbumInterface?> getAlbum(String albumId);

  /// Get tracks in an album
  Future<List<TrackInterface>> getAlbumTracks(String albumId,
      {int limit = 50, int offset = 0});

  /// Get new releases
  Future<List<AlbumInterface>> getNewReleases({int limit = 20, int offset = 0});

  /// Get a user's saved albums
  Future<List<AlbumInterface>> getSavedAlbums({int limit = 50, int offset = 0});

  /// Check if albums are saved in the user's library
  Future<List<bool>> isAlbumsSaved(List<String> albumIds);

  /// Save albums to the user's library
  Future<bool> saveAlbums(List<String> albumIds);

  /// Remove albums from the user's library
  Future<bool> removeAlbums(List<String> albumIds);
}
