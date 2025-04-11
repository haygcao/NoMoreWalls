import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 专辑服务接口
abstract class AlbumService extends BaseService {
  /// 获取专辑详情
  Future<AlbumInterface?> getAlbum(String albumId);
  
  /// 获取专辑曲目
  Future<List<TrackInterface>> getAlbumTracks(String albumId, {int limit = 20, int offset = 0});
  
  /// 获取新发行专辑
  Future<List<AlbumInterface>> getNewReleases({int limit = 20, int offset = 0});
  
  /// 获取艺术家的专辑
  Future<List<AlbumInterface>> getArtistAlbums(String artistId, {int limit = 20, int offset = 0});
}