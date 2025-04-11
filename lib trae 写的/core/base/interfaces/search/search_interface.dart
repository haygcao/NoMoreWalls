import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 定义搜索功能的基本接口
/// 所有平台的搜索实现都必须遵循这个接口
abstract class SearchInterface {
  /// 搜索音轨
  Future<List<TrackInterface>> searchTracks(String query,
      {int? limit, int? offset});

  /// 搜索专辑
  Future<List<AlbumInterface>> searchAlbums(String query,
      {int? limit, int? offset});

  /// 搜索艺术家
  Future<List<ArtistInterface>> searchArtists(String query,
      {int? limit, int? offset});

  /// 搜索所有类型的媒体内容
  Future<Map<String, List<dynamic>>> searchAll(String query, {int? limit});
}
