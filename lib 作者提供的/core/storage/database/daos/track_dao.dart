import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/tables/track_table.dart';

part '../../../../../lib我的/core/storage/database/daos/track_dao.g.dart';

/// 音轨数据访问对象
@DriftAccessor(tables: [TrackTable])
class TrackDao extends DatabaseAccessor<AppDatabase> with _$TrackDaoMixin {
  /// 构造函数
  TrackDao(AppDatabase db) : super(db);
  
  /// 获取所有音轨
  Future<List<TrackTableData>> getAllTracks() => select(trackTable).get();
  
  /// 根据ID获取音轨
  Future<TrackTableData?> getTrackById(String id, String platformId) {
    return (select(trackTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .getSingleOrNull();
  }
  
  /// 插入或更新音轨
  Future<int> insertOrUpdateTrack(TrackTableCompanion track) {
    return into(trackTable).insertOnConflictUpdate(track);
  }
  
  /// 删除音轨
  Future<int> deleteTrack(String id, String platformId) {
    return (delete(trackTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .go();
  }
  
  /// 删除所有音轨
  Future<int> deleteAllTracks() => delete(trackTable).go();
}