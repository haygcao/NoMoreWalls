abstract class MediaBase {
  String get id;  // 添加通用 id
  String get name;
  String? get releaseDate;
  String? get releaseDatePrecision;
  String? get artistName;
  String? get albumName;
  int? get durationMs;
  String? get imageUrl;  // 添加通用图片 URL
}