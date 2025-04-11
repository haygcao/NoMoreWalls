import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/search_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

abstract class SearchService implements SearchInterface {
  static const defaultLimit = 20;

  @override
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset});

  @override
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset});

  @override
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset});

  @override
  Future<Map<String, List<dynamic>>> searchAll(String query,
      {int? limit}) async {
    final tracks = await searchTracks(query, limit: limit);
    final albums = await searchAlbums(query, limit: limit);
    final artists = await searchArtists(query, limit: limit);

    return {
      'tracks': tracks,
      'albums': albums,
      'artists': artists,
    };
  }
}
