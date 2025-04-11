import 'package:spotube/core/base/models/base_model.dart';
import 'package:spotube/core/base/interfaces/auth/user_interface.dart';

/// 用户模型基类
abstract class UserModel extends BaseModel implements UserInterface {
  @override
  final String id;
  
  @override
  final String displayName;
  
  @override
  final String? email;
  
  @override
  final String? country;
  
  @override
  final String? imageUrl;
  
  @override
  final int? followersCount;
  
  UserModel({
    required this.id,
    required this.displayName,
    this.email,
    this.country,
    this.imageUrl,
    this.followersCount,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'country': country,
      'imageUrl': imageUrl,
      'followersCount': followersCount,
    };
  }
}