import 'package:drift/drift.dart';

/// 集合表
class CollectionTable extends Table {
  /// 表名
  @override
  String get tableName => 'collections';
  
  /// ID
  TextColumn get id => text()();
  
  /// 平台ID
  TextColumn get platformId => text()();
  
  /// 集合类型
  TextColumn get collectionType => text()();
  
  /// 描述
  TextColumn get description => text().nullable()();
  
  /// 曲目总数
  IntColumn get totalTracks => integer().withDefault(const Constant(0))();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 主键
  @override
  Set<Column> get primaryKey => {id, platformId, collectionType};
}