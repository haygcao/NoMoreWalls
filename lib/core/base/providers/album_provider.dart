import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/album_service.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/track_interface.dart';
import 'base_provider.dart';

/// Provider for album services
///
/// Manages state and operations related to albums
abstract class AlbumProvider extends BaseProvider<AlbumService> {
  /// Create a new album provider
  AlbumProvider() : super();

  /// Get an album by ID
  Future<AsyncValue<AlbumInterface>> getAlbum(String albumId) async {
    try {
      final album = await service.getAlbum(albumId);
      if (album == null) {
        throw Exception('Album not found');
      }
      return AsyncValue.data(album);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get tracks from an album
  Future<AsyncValue<List<TrackInterface>>> getAlbumTracks(String albumId,
      {int limit = 50, int offset = 0}) async {
    try {
      final tracks =
          await service.getAlbumTracks(albumId, limit: limit, offset: offset);
      return AsyncValue.data(tracks);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get new releases
  Future<AsyncValue<List<AlbumInterface>>> getNewReleases(
      {int limit = 20, int offset = 0}) async {
    try {
      final albums = await service.getNewReleases(limit: limit, offset: offset);
      return AsyncValue.data(albums);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get saved albums for the current user
  Future<AsyncValue<List<AlbumInterface>>> getSavedAlbums(
      {int limit = 20, int offset = 0}) async {
    try {
      final albums = await service.getSavedAlbums(limit: limit, offset: offset);
      return AsyncValue.data(albums);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Save an album for the current user
  Future<AsyncValue<bool>> saveAlbum(String albumId) async {
    try {
      final success = await service.saveAlbums([albumId]);
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Remove a saved album for the current user
  Future<AsyncValue<bool>> removeSavedAlbum(String albumId) async {
    try {
      final success = await service.removeAlbums([albumId]);
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Check if albums are saved for the current user
  Future<AsyncValue<List<bool>>> checkSavedAlbums(List<String> albumIds) async {
    try {
      final results = await service.isAlbumsSaved(albumIds);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }
}
