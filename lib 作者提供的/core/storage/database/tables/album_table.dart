import 'package:drift/drift.dart';

/// 专辑表
class AlbumTable extends Table {
  /// 表名
  @override
  String get tableName => 'albums';
  
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
  
  /// 发行日期
  DateTimeColumn get releaseDate => dateTime().nullable()();
  
  /// 艺术家ID列表（JSON格式）
  TextColumn get artistIds => text().nullable()();
  
  /// 艺术家名称列表（JSON格式）
  TextColumn get artistNames => text().nullable()();
  
  /// 专辑类型
  TextColumn get albumType => text().nullable()();
  
  /// 曲目总数
  IntColumn get totalTracks => integer().withDefault(const Constant(0))();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 主键
  @override
  Set<Column> get primaryKey => {id, platformId};
}