import 'package:drift/drift.dart';

/// 艺术家表
class ArtistTable extends Table {
  /// 表名
  @override
  String get tableName => 'artists';
  
  /// ID
  TextColumn get id => text()();
  
  /// 平台ID
  TextColumn get platformId => text()();
  
  /// 名称
  TextColumn get name => text()();
  
  /// 描述
  TextColumn get description => text().nullable()();
  
  /// 图片URL
  TextColumn get imageUrl => text().nullable()();
  
  /// 流派（JSON格式）
  TextColumn get genres => text().nullable()();
  
  /// 粉丝数量
  IntColumn get followersCount => integer().nullable()();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 主键
  @override
  Set<Column> get primaryKey => {id, platformId};
}