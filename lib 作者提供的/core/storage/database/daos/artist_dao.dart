import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/tables/artist_table.dart';

part '../../../../../lib我的/core/storage/database/daos/artist_dao.g.dart';

/// 艺术家数据访问对象
@DriftAccessor(tables: [ArtistTable])
class ArtistDao extends DatabaseAccessor<AppDatabase> with _$ArtistDaoMixin {
  /// 构造函数
  ArtistDao(AppDatabase db) : super(db);
  
  /// 获取所有艺术家
  Future<List<ArtistTableData>> getAllArtists() => select(artistTable).get();
  
  /// 根据ID获取艺术家
  Future<ArtistTableData?> getArtistById(String id, String platformId) {
    return (select(artistTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .getSingleOrNull();
  }
  
  /// 插入或更新艺术家
  Future<int> insertOrUpdateArtist(ArtistTableCompanion artist) {
    return into(artistTable).insertOnConflictUpdate(artist);
  }
  
  /// 删除艺术家
  Future<int> deleteArtist(String id, String platformId) {
    return (delete(artistTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .go();
  }
  
  /// 删除所有艺术家
  Future<int> deleteAllArtists() => delete(artistTable).go();
}