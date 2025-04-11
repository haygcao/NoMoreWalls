import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/tables/album_table.dart';

part '../../../../../lib我的/core/storage/database/daos/album_dao.g.dart';

/// 专辑数据访问对象
@DriftAccessor(tables: [AlbumTable])
class AlbumDao extends DatabaseAccessor<AppDatabase> with _$AlbumDaoMixin {
  /// 构造函数
  AlbumDao(AppDatabase db) : super(db);
  
  /// 获取所有专辑
  Future<List<AlbumTableData>> getAllAlbums() => select(albumTable).get();
  
  /// 根据ID获取专辑
  Future<AlbumTableData?> getAlbumById(String id, String platformId) {
    return (select(albumTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .getSingleOrNull();
  }
  
  /// 插入或更新专辑
  Future<int> insertOrUpdateAlbum(AlbumTableCompanion album) {
    return into(albumTable).insertOnConflictUpdate(album);
  }
  
  /// 删除专辑
  Future<int> deleteAlbum(String id, String platformId) {
    return (delete(albumTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .go();
  }
  
  /// 删除所有专辑
  Future<int> deleteAllAlbums() => delete(albumTable).go();
}