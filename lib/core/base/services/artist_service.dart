import 'package:flutter/foundation.dart';
import 'base_service.dart';
import '../interfaces/media/artist_interface.dart';
import '../interfaces/media/album_interface.dart';
import '../interfaces/media/track_interface.dart';

/// Base class for artist services
///
/// Provides methods for retrieving artist information across platforms
abstract class ArtistService extends BaseService {
  /// Get an artist by ID
  Future<ArtistInterface?> getArtist(String artistId);

  /// Get an artist's albums
  Future<List<AlbumInterface>> getArtistAlbums(String artistId,
      {int limit = 20, int offset = 0});

  /// Get an artist's top tracks
  Future<List<TrackInterface>> getArtistTopTracks(String artistId,
      {int limit = 10});

  /// Get related artists
  Future<List<ArtistInterface>> getRelatedArtists(String artistId,
      {int limit = 20});

  /// Get a user's followed artists
  Future<List<ArtistInterface>> getFollowedArtists(
      {int limit = 50, int offset = 0});

  /// Check if the user follows artists
  Future<List<bool>> isFollowingArtists(List<String> artistIds);

  /// Follow artists
  Future<bool> followArtists(List<String> artistIds);

  /// Unfollow artists
  Future<bool> unfollowArtists(List<String> artistIds);
}
