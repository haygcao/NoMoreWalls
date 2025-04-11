import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/media/track_interface.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/artist_interface.dart';
import '../interfaces/media/playlist_interface.dart';
import '../interfaces/media/collection_interface.dart';

/// Base class for media services
///
/// Provides methods for searching and retrieving media across platforms
abstract class MediaService extends BaseService {
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

  /// Get tracks from a playlist
  Future<List<TrackInterface>> getPlaylistTracks(String playlistId,
      {int limit = 50, int offset = 0});

  /// Get tracks from an album
  Future<List<TrackInterface>> getAlbumTracks(String albumId,
      {int limit = 50, int offset = 0});

  /// Get albums by an artist
  Future<List<AlbumInterface>> getArtistAlbums(String artistId,
      {int limit = 20, int offset = 0});

  /// Get top tracks by an artist
  Future<List<TrackInterface>> getArtistTopTracks(String artistId,
      {int limit = 10});

  /// Get related artists
  Future<List<ArtistInterface>> getRelatedArtists(String artistId,
      {int limit = 20});

  /// Get featured playlists
  Future<List<PlaylistInterface>> getFeaturedPlaylists(
      {int limit = 20, int offset = 0});

  /// Get new releases
  Future<List<AlbumInterface>> getNewReleases({int limit = 20, int offset = 0});

  /// Get recommendations based on seed tracks, artists, or genres
  Future<List<TrackInterface>> getRecommendations({
    List<String> seedTracks = const [],
    List<String> seedArtists = const [],
    List<String> seedGenres = const [],
    int limit = 20,
  });

  /// Get a track by ID
  Future<TrackInterface?> getTrack(String trackId);

  /// Get an album by ID
  Future<AlbumInterface?> getAlbum(String albumId);

  /// Get an artist by ID
  Future<ArtistInterface?> getArtist(String artistId);

  /// Get a playlist by ID
  Future<PlaylistInterface?> getPlaylist(String playlistId);

  /// Get available genres
  Future<List<String>> getAvailableGenres();
}
