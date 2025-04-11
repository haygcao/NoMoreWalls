import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/tables/collection_table.dart';

part '../../../../../lib我的/core/storage/database/daos/collection_dao.g.dart';

/// 集合数据访问对象
@DriftAccessor(tables: [CollectionTable])
class CollectionDao extends DatabaseAccessor<AppDatabase> with _$CollectionDaoMixin {
  /// 构造函数
  CollectionDao(AppDatabase db) : super(db);
  
  /// 获取所有集合
  Future<List<CollectionTableData>> getAllCollections() => select(collectionTable).get();
  
  /// 根据ID获取集合
  Future<CollectionTableData?> getCollectionById(String id, String platformId, String collectionType) {
    return (select(collectionTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId) & t.collectionType.equals(collectionType)))
      .getSingleOrNull();
  }
  
  /// 插入或更新集合
  Future<int> insertOrUpdateCollection(CollectionTableCompanion collection) {
    return into(collectionTable).insertOnConflictUpdate(collection);
  }
  
  /// 删除集合
  Future<int> deleteCollection(String id, String platformId, String collectionType) {
    return (delete(collectionTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId) & t.collectionType.equals(collectionType)))
      .go();
  }
  
  /// 删除所有集合
  Future<int> deleteAllCollections() => delete(collectionTable).go();
}