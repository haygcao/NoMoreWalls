import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/playlist_interface.dart';

/// 搜索服务接口
abstract class SearchService extends BaseService {
  /// 搜索曲目
  Future<List<TrackInterface>> searchTracks(String query, {int limit = 20, int offset = 0});
  
  /// 搜索专辑
  Future<List<AlbumInterface>> searchAlbums(String query, {int limit = 20, int offset = 0});
  
  /// 搜索艺术家
  Future<List<ArtistInterface>> searchArtists(String query, {int limit = 20, int offset = 0});
  
  /// 搜索播放列表
  Future<List<PlaylistInterface>> searchPlaylists(String query, {int limit = 20, int offset = 0});
  
  /// 综合搜索
  Future<Map<String, List<dynamic>>> search(String query, {int limit = 20, int offset = 0});
}