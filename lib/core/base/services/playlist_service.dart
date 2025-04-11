import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/media/playlist_interface.dart';
import '../interfaces/media/track_interface.dart';

/// Base class for playlist services
///
/// Provides methods for managing playlists across platforms
abstract class PlaylistService extends BaseService {
  /// Get a user's playlists
  Future<List<PlaylistInterface>> getUserPlaylists(
      {int limit = 50, int offset = 0});

  /// Get a playlist by ID
  Future<PlaylistInterface?> getPlaylist(String playlistId);

  /// Get tracks in a playlist
  Future<List<TrackInterface>> getPlaylistTracks(String playlistId,
      {int limit = 100, int offset = 0});

  /// Create a new playlist
  Future<PlaylistInterface?> createPlaylist({
    required String name,
    String? description,
    bool public = false,
    bool collaborative = false,
  });

  /// Update a playlist's details
  Future<bool> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    bool? public,
    bool? collaborative,
  });

  /// Add tracks to a playlist
  Future<bool> addTracksToPlaylist({
    required String playlistId,
    required List<String> trackIds,
    int position = 0,
  });

  /// Remove tracks from a playlist
  Future<bool> removeTracksFromPlaylist({
    required String playlistId,
    required List<String> trackIds,
  });

  /// Reorder tracks in a playlist
  Future<bool> reorderPlaylistTracks({
    required String playlistId,
    required int rangeStart,
    required int insertBefore,
    required int rangeLength,
  });

  /// Delete a playlist
  Future<bool> deletePlaylist(String playlistId);

  /// Check if a user follows a playlist
  Future<bool> isFollowingPlaylist(String playlistId);

  /// Follow a playlist
  Future<bool> followPlaylist(String playlistId);

  /// Unfollow a playlist
  Future<bool> unfollowPlaylist(String playlistId);

  /// Get featured playlists
  Future<List<PlaylistInterface>> getFeaturedPlaylists(
      {int limit = 20, int offset = 0});
}
