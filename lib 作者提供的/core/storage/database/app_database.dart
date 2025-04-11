import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/database_config.dart';
import 'package:spotube/core/storage/database/tables/track_table.dart';
import 'package:spotube/core/storage/database/tables/album_table.dart';
import 'package:spotube/core/storage/database/tables/artist_table.dart';
import 'package:spotube/core/storage/database/tables/playlist_table.dart';
import 'package:spotube/core/storage/database/tables/user_table.dart';
import 'package:spotube/core/storage/database/tables/collection_table.dart';

part '../../../../lib我的/core/storage/database/app_database.g.dart';

/// 应用数据库
@DriftDatabase(
  tables: [
    TrackTable,
    AlbumTable,
    ArtistTable,
    PlaylistTable,
    UserTable,
    CollectionTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// 数据库配置
  final DatabaseConfig config;
  
  /// 构造函数
  AppDatabase(this.config) : super(_openConnection(config));
  
  /// 获取数据库版本
  @override
  int get schemaVersion => config.version;
  
  /// 数据库迁移
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 处理数据库升级
    },
  );
  
  /// 关闭数据库
  Future<void> closeDatabase() async {
    await close();
  }
}

/// 打开数据库连接
QueryExecutor _openConnection(DatabaseConfig config) {
  // 根据平台选择不同的数据库实现
  // 这里需要根据实际情况实现
  throw UnimplementedError('需要根据平台实现数据库连接');
}