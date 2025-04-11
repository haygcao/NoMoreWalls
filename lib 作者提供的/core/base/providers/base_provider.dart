/// 所有提供者的基础接口
abstract class BaseProvider<T> {
  /// 获取数据
  Future<T> getData();
  
  /// 刷新数据
  Future<void> refresh();
  
  /// 数据是否已加载
  bool get isLoaded;
  
  /// 是否正在加载
  bool get isLoading;
  
  /// 是否出错
  bool get hasError;
  
  /// 错误信息
  dynamic get error;
}