// 基础用户接口
abstract class UserBase {
  String? get id;
  String? get name;
  String? get email;
  String? get imageUrl;
  String get platform;
  
  Map<String, dynamic> toJson();
}

/// 通用用户模型，不依赖于特定平台
class User implements UserBase {
  @override
  final String? id;
  
  @override
  final String? name;
  
  @override
  final String? email;
  
  @override
  final String? imageUrl;
  
  @override
  final String platform;
  
  // 额外的属性
  final String? country;
  final int? followersCount;
  final String? subscriptionType;
  final String? birthdate;
  final Map<String, dynamic> platformMetadata;

  const User({
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    required this.platform,
    this.country,
    this.followersCount,
    this.subscriptionType,
    this.birthdate,
    this.platformMetadata = const {},
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'imageUrl': imageUrl,
    'platform': platform,
    'country': country,
    'followersCount': followersCount,
    'subscriptionType': subscriptionType,
    'birthdate': birthdate,
    'platformMetadata': platformMetadata,
  };
}
