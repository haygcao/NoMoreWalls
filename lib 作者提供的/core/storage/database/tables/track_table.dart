import 'package:drift/drift.dart';

/// 音轨表
class TrackTable extends Table {
  /// 表名
  @override
  String get tableName => 'tracks';
  
  /// ID
  TextColumn get id => text()();
  
  /// 平台ID
  TextColumn get platformId => text()();
  
  /// 名称
  TextColumn get name => text()();
  
  /// 艺术家名称
  TextColumn get artistName => text().nullable()();
  
  /// 专辑名称
  TextColumn get albumName => text().nullable()();
  
  /// 时长（毫秒）
  IntColumn get durationMs => integer().nullable()();
  
  /// 图片URL
  TextColumn get imageUrl => text().nullable()();
  
  /// 是否可播放
  BoolColumn get isPlayable => boolean().withDefault(const Constant(true))();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 主键
  @override
  Set<Column> get primaryKey => {id, platformId};
}