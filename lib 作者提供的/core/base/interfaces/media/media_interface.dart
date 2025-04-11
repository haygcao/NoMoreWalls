/// 媒体接口，所有媒体类型的基础接口
abstract class MediaInterface {
  /// 唯一标识符
  String get id;
  
  /// 名称
  String get name;
  
  /// 图片URL
  String? get imageUrl;
  
  /// 媒体类型
  String get type;
  
  /// 将对象转换为JSON
  Map<String, dynamic> toJson();
}