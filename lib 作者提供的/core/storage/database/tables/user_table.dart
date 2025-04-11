import 'package:drift/drift.dart';

/// 用户表
class UserTable extends Table {
  /// 表名
  @override
  String get tableName => 'users';
  
  /// ID
  TextColumn get id => text()();
  
  /// 平台ID
  TextColumn get platformId => text()();
  
  /// 显示名称
  TextColumn get displayName => text()();
  
  /// 电子邮件
  TextColumn get email => text().nullable()();
  
  /// 国家/地区
  TextColumn get country => text().nullable()();
  
  /// 图片URL
  TextColumn get imageUrl => text().nullable()();
  
  /// 粉丝数量
  IntColumn get followersCount => integer().nullable()();
  
  /// 访问令牌
  TextColumn get accessToken => text().nullable()();
  
  /// 刷新令牌
  TextColumn get refreshToken => text().nullable()();
  
  /// 令牌过期时间
  DateTimeColumn get tokenExpirationTime => dateTime().nullable()();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 主键
  @override
  Set<Column> get primaryKey => {id, platformId};
}