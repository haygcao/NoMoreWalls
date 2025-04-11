/// 用户接口
abstract class UserInterface {
  /// 唯一标识符
  String get id;
  
  /// 显示名称
  String get displayName;
  
  /// 电子邮件
  String? get email;
  
  /// 国家/地区
  String? get country;
  
  /// 头像URL
  String? get imageUrl;
  
  /// 粉丝数量
  int? get followersCount;
  
  /// 将对象转换为JSON
  Map<String, dynamic> toJson();
}