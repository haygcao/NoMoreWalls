import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/services/search_service.dart';
import 'package:spotube/platforms/spotify/adapters/spotify_album_adapter.dart';
import 'package:spotube/platforms/spotify/adapters/spotify_artist_adapter.dart';
import 'package:spotube/platforms/spotify/adapters/spotify_track_adapter.dart';

class SpotifySearchService extends SearchService {
  @override
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset}) async {
    // 实现Spotify特定的搜索逻辑
    throw UnimplementedError();
  }

  @override
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset}) async {
    // 实现Spotify特定的搜索逻辑
    throw UnimplementedError();
  }

  @override
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset}) async {
    // 实现Spotify特定的搜索逻辑
    throw UnimplementedError();
  }
}

final spotifySearchServiceProvider = Provider<SpotifySearchService>((ref) {
  return SpotifySearchService();
});
