// 基础用户接口
abstract class UserBase {
  String? get id;
  String? get name;
  String? get email;
  String? get imageUrl;
  String get platform;
  
  Map<String, dynamic> toJson();
}