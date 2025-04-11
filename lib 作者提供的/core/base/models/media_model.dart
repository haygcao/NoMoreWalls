import 'package:spotube/core/base/models/base_model.dart';
import 'package:spotube/core/base/interfaces/media/media_interface.dart';

/// 媒体模型基类
abstract class MediaModel extends BaseModel implements MediaInterface {
  @override
  final String id;
  
  @override
  final String name;
  
  @override
  final String? imageUrl;
  
  @override
  final String type;
  
  MediaModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.type,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'type': type,
    };
  }
}