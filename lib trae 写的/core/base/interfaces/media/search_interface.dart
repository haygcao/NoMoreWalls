import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

abstract class SearchInterface {
  /// Search for tracks with the given query
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset});

  /// Search for albums with the given query
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset});

  /// Search for artists with the given query
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset});

  /// Search for all media types with the given query
  Future<Map<String, List<dynamic>>> searchAll(String query, {int? limit});
}
