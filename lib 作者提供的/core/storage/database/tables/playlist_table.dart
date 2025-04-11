import 'package:drift/drift.dart';

/// 播放列表表
class PlaylistTable extends Table {
  /// 表名
  @override
  String get tableName => 'playlists';
  
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
  
  /// 创建者
  TextColumn get owner => text().nullable()();
  
  /// 是否公开
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();
  
  /// 是否协作
  BoolColumn get collaborative => boolean().withDefault(const Constant(false))();
  
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