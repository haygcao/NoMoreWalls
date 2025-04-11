import 'package:drift/drift.dart';
import 'package:spotube/core/storage/database/app_database.dart';
import 'package:spotube/core/storage/database/tables/user_table.dart';

part '../../../../../lib我的/core/storage/database/daos/user_dao.g.dart';

/// 用户数据访问对象
@DriftAccessor(tables: [UserTable])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  /// 构造函数
  UserDao(AppDatabase db) : super(db);
  
  /// 获取所有用户
  Future<List<UserTableData>> getAllUsers() => select(userTable).get();
  
  /// 根据ID获取用户
  Future<UserTableData?> getUserById(String id, String platformId) {
    return (select(userTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .getSingleOrNull();
  }
  
  /// 插入或更新用户
  Future<int> insertOrUpdateUser(UserTableCompanion user) {
    return into(userTable).insertOnConflictUpdate(user);
  }
  
  /// 删除用户
  Future<int> deleteUser(String id, String platformId) {
    return (delete(userTable)
      ..where((t) => t.id.equals(id) & t.platformId.equals(platformId)))
      .go();
  }
  
  /// 删除所有用户
  Future<int> deleteAllUsers() => delete(userTable).go();
}