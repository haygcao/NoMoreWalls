import 'package:spotube/core/base/interfaces/media/media_interface.dart';

/// 艺术家接口
abstract class ArtistInterface extends MediaInterface {
  /// 描述
  String? get description;
  
  /// 流派
  List<String>? get genres;
  
  /// 粉丝数量
  int? get followersCount;
}