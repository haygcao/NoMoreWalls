import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/playlist_service.dart';
import '../interfaces/media/playlist_interface.dart';
import '../interfaces/media/track_interface.dart';
import 'base_provider.dart';

/// Provider for playlist services
///
/// Manages state and operations related to playlists
abstract class PlaylistProvider extends BaseProvider<PlaylistService> {
  /// Create a new playlist provider
  PlaylistProvider() : super();

  /// Get a playlist by ID
  Future<AsyncValue<PlaylistInterface?>> getPlaylist(String playlistId) async {
    try {
      final playlist = await service.getPlaylist(playlistId);
      return AsyncValue.data(playlist);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get tracks from a playlist
  Future<AsyncValue<List<TrackInterface>>> getPlaylistTracks(String playlistId,
      {int limit = 50, int offset = 0}) async {
    try {
      final tracks = await service.getPlaylistTracks(playlistId,
          limit: limit, offset: offset);
      return AsyncValue.data(tracks);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get user playlists
  Future<AsyncValue<List<PlaylistInterface>>> getUserPlaylists(
      {int limit = 20, int offset = 0}) async {
    try {
      final playlists =
          await service.getUserPlaylists(limit: limit, offset: offset);
      return AsyncValue.data(playlists);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Create a new playlist
  Future<AsyncValue<PlaylistInterface?>> createPlaylist({
    required String name,
    String? description,
    bool public = false,
    bool collaborative = false,
  }) async {
    try {
      final playlist = await service.createPlaylist(
        name: name,
        description: description,
        public: public,
        collaborative: collaborative,
      );
      return AsyncValue.data(playlist);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Update a playlist
  Future<AsyncValue<bool>> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    bool? public,
    bool? collaborative,
  }) async {
    try {
      final success = await service.updatePlaylist(
        playlistId: playlistId,
        name: name,
        description: description,
        public: public,
        collaborative: collaborative,
      );
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a playlist
  Future<AsyncValue<bool>> deletePlaylist(String playlistId) async {
    try {
      final success = await service.deletePlaylist(playlistId);
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Add tracks to a playlist
  Future<AsyncValue<bool>> addTracksToPlaylist({
    required String playlistId,
    required List<String> trackIds,
    int position = 0,
  }) async {
    try {
      final success = await service.addTracksToPlaylist(
        playlistId: playlistId,
        trackIds: trackIds,
        position: position,
      );
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Remove tracks from a playlist
  Future<AsyncValue<bool>> removeTracksFromPlaylist({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    try {
      final success = await service.removeTracksFromPlaylist(
        playlistId: playlistId,
        trackIds: trackIds,
      );
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Reorder tracks in a playlist
  Future<AsyncValue<bool>> reorderPlaylistTracks({
    required String playlistId,
    required int rangeStart,
    required int insertBefore,
    required int rangeLength,
  }) async {
    try {
      final success = await service.reorderPlaylistTracks(
        playlistId: playlistId,
        rangeStart: rangeStart,
        insertBefore: insertBefore,
        rangeLength: rangeLength,
      );
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get featured playlists
  Future<AsyncValue<List<PlaylistInterface>>> getFeaturedPlaylists(
      {int limit = 20, int offset = 0}) async {
    try {
      final playlists =
          await service.getFeaturedPlaylists(limit: limit, offset: offset);
      return AsyncValue.data(playlists);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }
}
