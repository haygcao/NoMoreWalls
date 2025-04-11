import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_service.dart';
import 'base_provider.dart';

/// Provider for media services
///
/// Manages state and operations related to media content (tracks, albums, artists, playlists)
abstract class MediaProvider extends BaseProvider<MediaService> {
  /// Create a new media provider
  MediaProvider() : super();

  /// Search for tracks matching the query
  Future<AsyncValue<List<dynamic>>> searchTracks(String query,
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
  Future<AsyncValue<List<dynamic>>> searchAlbums(String query,
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
  Future<AsyncValue<List<dynamic>>> searchArtists(String query,
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
  Future<AsyncValue<List<dynamic>>> searchPlaylists(String query,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.searchPlaylists(query, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get tracks from a playlist
  Future<AsyncValue<List<dynamic>>> getPlaylistTracks(String playlistId,
      {int limit = 50, int offset = 0}) async {
    try {
      final results = await service.getPlaylistTracks(playlistId,
          limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get tracks from an album
  Future<AsyncValue<List<dynamic>>> getAlbumTracks(String albumId,
      {int limit = 50, int offset = 0}) async {
    try {
      final results =
          await service.getAlbumTracks(albumId, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get albums by an artist
  Future<AsyncValue<List<dynamic>>> getArtistAlbums(String artistId,
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.getArtistAlbums(artistId, limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get top tracks by an artist
  Future<AsyncValue<List<dynamic>>> getArtistTopTracks(String artistId,
      {int limit = 10}) async {
    try {
      final results = await service.getArtistTopTracks(artistId, limit: limit);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get related artists
  Future<AsyncValue<List<dynamic>>> getRelatedArtists(String artistId,
      {int limit = 20}) async {
    try {
      final results = await service.getRelatedArtists(artistId, limit: limit);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get featured playlists
  Future<AsyncValue<List<dynamic>>> getFeaturedPlaylists(
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.getFeaturedPlaylists(limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get new releases
  Future<AsyncValue<List<dynamic>>> getNewReleases(
      {int limit = 20, int offset = 0}) async {
    try {
      final results =
          await service.getNewReleases(limit: limit, offset: offset);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }
}
