/// 事件接口
abstract class EventInterface {
  /// 事件类型
  String get type;
  
  /// 事件数据
  Map<String, dynamic> get data;
  
  /// 事件时间戳
  DateTime get timestamp;
}