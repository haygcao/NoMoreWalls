import 'package:spotube/core/base/providers/base_provider.dart';
import 'package:spotube/core/base/interfaces/media/media_interface.dart';

/// 媒体提供者接口
abstract class MediaProvider<T extends MediaInterface> extends BaseProvider<T> {
  /// 媒体ID
  String get mediaId;
  
  /// 媒体类型
  String get mediaType;
}