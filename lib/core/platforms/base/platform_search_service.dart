import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/services/search_service.dart';

/// 平台特定的搜索服务基类
/// 所有平台的搜索实现都应该继承这个类
abstract class PlatformSearchService extends SearchService {
  @override
  final String platform;

  @override
  final int priority;

  PlatformSearchService({
    required this.platform,
    required this.priority,
  });

  /// 检查平台服务是否可用
  Future<bool> get isAvailable;

  /// 初始化平台特定的配置
  Future<void> initialize();

  /// 清理平台特定的资源
  Future<void> dispose();

  @override
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset}) async {
    if (!await isAvailable) {
      throw UnsupportedError('$platform search service is not available');
    }
    return performSearchTracks(query, limit: limit, offset: offset);
  }

  @override
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset}) async {
    if (!await isAvailable) {
      throw UnsupportedError('$platform search service is not available');
    }
    return performSearchAlbums(query, limit: limit, offset: offset);
  }

  @override
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset}) async {
    if (!await isAvailable) {
      throw UnsupportedError('$platform search service is not available');
    }
    return performSearchArtists(query, limit: limit, offset: offset);
  }

  /// 执行平台特定的音轨搜索
  Future<List<TrackInterface>> performSearchTracks(String query,
      {int? limit, int? offset});

  /// 执行平台特定的专辑搜索
  Future<List<AlbumInterface>> performSearchAlbums(String query,
      {int? limit, int? offset});

  /// 执行平台特定的艺术家搜索
  Future<List<ArtistInterface>> performSearchArtists(String query,
      {int? limit, int? offset});
}
