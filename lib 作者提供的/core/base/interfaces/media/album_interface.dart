import 'package:spotube/core/base/interfaces/media/media_interface.dart';
import 'package:spotube/core/base/interfaces/media/collection_interface.dart';

/// 专辑接口
abstract class AlbumInterface extends MediaInterface implements CollectionInterface {
  /// 描述
  String? get description;
  
  /// 发行日期
  DateTime? get releaseDate;
  
  /// 艺术家ID列表
  List<String>? get artistIds;
  
  /// 艺术家名称列表
  List<String>? get artistNames;
  
  /// 专辑类型
  String? get albumType;
  
  /// 曲目总数
  int get totalTracks;
}