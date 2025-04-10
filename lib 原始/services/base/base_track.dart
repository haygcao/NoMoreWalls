

/// 统一的音轨接口
abstract class BaseTrack {
  String get id;
  String get title;
  String? get artistName;
  String? get albumName;
  Duration? get duration;

  Map<String, dynamic> toJson();
}

/// 扩展的音轨接口，添加发布日期
abstract class ExtendedBaseTrack extends BaseTrack {
  DateTime? get releaseDate;
}