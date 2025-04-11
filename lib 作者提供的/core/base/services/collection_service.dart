import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/media/collection_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 集合服务接口
abstract class CollectionService extends BaseService {
  /// 获取集合详情
  Future<CollectionInterface?> getCollection(String collectionId, String collectionType);
  
  /// 获取集合曲目
  Future<List<TrackInterface>> getCollectionTracks(String collectionId, String collectionType, {int limit = 20, int offset = 0});
}