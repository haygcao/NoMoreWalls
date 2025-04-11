/// 数据库配置
class DatabaseConfig {
  /// 数据库名称
  final String databaseName;
  
  /// 数据库版本
  final int version;
  
  /// 是否记录SQL语句
  final bool logStatements;
  
  /// 构造函数
  DatabaseConfig({
    required this.databaseName,
    required this.version,
    this.logStatements = false,
  });
}