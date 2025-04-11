/// 集合接口，用于专辑和播放列表等包含多个曲目的媒体类型
abstract class CollectionInterface {
  /// 描述
  String? get description;
  
  /// 曲目总数
  int get totalTracks;
}