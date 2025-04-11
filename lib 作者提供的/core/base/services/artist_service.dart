import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';

/// 艺术家服务接口
abstract class ArtistService extends BaseService {
  /// 获取艺术家详情
  Future<ArtistInterface?> getArtist(String artistId);
  
  /// 获取艺术家热门曲目
  Future<List<TrackInterface>> getArtistTopTracks(String artistId, {int limit = 10});
  
  /// 获取相关艺术家
  Future<List<ArtistInterface>> getRelatedArtists(String artistId, {int limit = 20});
  
  /// 获取推荐艺术家
  Future<List<ArtistInterface>> getRecommendedArtists({int limit = 20, int offset = 0});
}