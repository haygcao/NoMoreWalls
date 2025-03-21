part of '../database.dart';



@DataClassName('PlaylistTableData')
class PlaylistTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get source => text()(); // 添加来源字段，如 'spotify', 'youtube' 等
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();
  // ... 其他字段
}