import 'package:spotube/core/base/providers/media_provider.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';

/// 艺术家提供者接口
abstract class ArtistProvider extends MediaProvider<ArtistInterface> {
  /// 获取艺术家热门曲目
  Future<List<TrackInterface>> getTopTracks({int limit = 10});
  
  /// 获取艺术家专辑
  Future<List<AlbumInterface>> getAlbums({int limit = 20, int offset = 0});
  
  /// 获取相关艺术家
  Future<List<ArtistInterface>> getRelatedArtists({int limit = 20});
  
  /// 艺术家热门曲目
  List<TrackInterface> get topTracks;
  
  /// 艺术家专辑
  List<AlbumInterface> get albums;
  
  /// 相关艺术家
  List<ArtistInterface> get relatedArtists;
  
  /// 热门曲目是否已加载
  bool get topTracksLoaded;
  
  /// 专辑是否已加载
  bool get albumsLoaded;
  
  /// 相关艺术家是否已加载
  bool get relatedArtistsLoaded;
}