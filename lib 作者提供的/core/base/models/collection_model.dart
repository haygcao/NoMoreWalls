import 'package:spotube/core/base/models/base_model.dart';
import 'package:spotube/core/base/interfaces/media/collection_interface.dart';

/// 集合模型基类
abstract class CollectionModel extends BaseModel implements CollectionInterface {
  @override
  final String? description;
  
  @override
  final int totalTracks;
  
  CollectionModel({
    required this.description,
    required this.totalTracks,
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'totalTracks': totalTracks,
    };
  }
}