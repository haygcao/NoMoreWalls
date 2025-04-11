import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/tables/playlist_table.dart';

part '../../../../../lib我的/core/storage/database/daos/playlist_dao.g.dart';

/// 播放列表数据访问对象
@DriftAccessor(tables: [PlaylistTable])
class PlaylistDao extends DatabaseAccessor<AppDatabase> with _$PlaylistDaoMixin {
  /// 构造函数
  PlaylistDao(AppDatabase db) : super(db);
  
  /// 获取所有播放列表
  Future<List<PlaylistTableData>> getAllPlaylists() => select(playlistTable).get();
  
  /// 根据ID获取播放列表
  Future<PlaylistTableData?> getPlaylistById(String id, String platformId) {
    return (select(playlistTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .getSingleOrNull();
  }
  
  /// 插入或更新播放列表
  Future<int> insertOrUpdatePlaylist(PlaylistTableCompanion playlist) {
    return into(playlistTable).insertOnConflictUpdate(playlist);
  }
  
  /// 删除播放列表
  Future<int> deletePlaylist(String id, String platformId) {
    return (delete(playlistTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .go();
  }
  
  /// 删除所有播放列表
  Future<int> deleteAllPlaylists() => delete(playlistTable).go();
}