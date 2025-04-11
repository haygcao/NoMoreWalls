import 'package:spotube/core/base/interfaces/media/media_interface.dart';
import 'package:spotube/core/base/interfaces/media/collection_interface.dart';

/// 播放列表接口
abstract class PlaylistInterface extends MediaInterface implements CollectionInterface {
  /// 描述
  String? get description;
  
  /// 创建者
  String? get owner;
  
  /// 是否公开
  bool get isPublic;
  
  /// 是否协作
  bool get collaborative;
  
  /// 曲目总数
  int get totalTracks;
}