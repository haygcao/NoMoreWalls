import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/artist_service.dart';
import '../interfaces/media/artist_interface.dart';
import '../interfaces/media/track_interface.dart';
import '../interfaces/media/album_interface.dart';
import 'base_provider.dart';

/// Provider for artist services
///
/// Manages state and operations related to artists
abstract class ArtistProvider extends BaseProvider<ArtistService> {
  /// Create a new artist provider
  ArtistProvider() : super();

  /// Get an artist by ID
  Future<AsyncValue<ArtistInterface>> getArtist(String artistId) async {
    try {
      final artist = await service.getArtist(artistId);
      if (artist == null) {
        throw Exception('Artist not found');
      }
      return AsyncValue.data(artist);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get top tracks by an artist
  Future<AsyncValue<List<TrackInterface>>> getArtistTopTracks(String artistId,
      {int limit = 10}) async {
    try {
      final tracks = await service.getArtistTopTracks(artistId, limit: limit);
      return AsyncValue.data(tracks);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get albums by an artist
  Future<AsyncValue<List<AlbumInterface>>> getArtistAlbums(String artistId,
      {int limit = 20, int offset = 0}) async {
    try {
      final albums =
          await service.getArtistAlbums(artistId, limit: limit, offset: offset);
      return AsyncValue.data(albums);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get related artists
  Future<AsyncValue<List<ArtistInterface>>> getRelatedArtists(String artistId,
      {int limit = 20}) async {
    try {
      final artists = await service.getRelatedArtists(artistId, limit: limit);
      return AsyncValue.data(artists);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Get followed artists for the current user
  Future<AsyncValue<List<ArtistInterface>>> getFollowedArtists(
      {int limit = 20, int offset = 0}) async {
    try {
      final artists =
          await service.getFollowedArtists(limit: limit, offset: offset);
      return AsyncValue.data(artists);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Follow an artist for the current user
  Future<AsyncValue<bool>> followArtist(String artistId) async {
    try {
      final success = await service.followArtists([artistId]);
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Unfollow an artist for the current user
  Future<AsyncValue<bool>> unfollowArtist(String artistId) async {
    try {
      final success = await service.unfollowArtists([artistId]);
      return AsyncValue.data(success);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }

  /// Check if artists are followed by the current user
  Future<AsyncValue<List<bool>>> checkFollowedArtists(
      List<String> artistIds) async {
    try {
      final results = await service.isFollowingArtists(artistIds);
      return AsyncValue.data(results);
    } catch (e, stackTrace) {
      return AsyncValue.error(e, stackTrace);
    }
  }
}
