import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/interfaces/media/media_interface.dart';

/// 媒体服务接口
abstract class MediaService extends BaseService {
  /// 获取媒体详情
  Future<MediaInterface?> getMedia(String mediaId, String mediaType);
}