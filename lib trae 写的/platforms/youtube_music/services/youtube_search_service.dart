import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/services/search_service.dart';
import 'package:spotube/platforms/youtube_music/adapters/youtube_album_adapter.dart';
import 'package:spotube/platforms/youtube_music/adapters/youtube_artist_adapter.dart';
import 'package:spotube/platforms/youtube_music/adapters/youtube_track_adapter.dart';

class YouTubeSearchService extends SearchService {
  @override
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset}) async {
    // 实现YouTube Music特定的搜索逻辑
    throw UnimplementedError();
  }

  @override
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset}) async {
    // 实现YouTube Music特定的搜索逻辑
    throw UnimplementedError();
  }

  @override
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset}) async {
    // 实现YouTube Music特定的搜索逻辑
    throw UnimplementedError();
  }
}

final youtubeSearchServiceProvider = Provider<YouTubeSearchService>((ref) {
  return YouTubeSearchService();
});
