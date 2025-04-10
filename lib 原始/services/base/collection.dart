abstract class Collection {
  String get id;
  String get name;
  String? get description;
  String? get imageUrl;
  String get uri;  // 统一资源标识符（可以是 Spotify URI 或 YouTube URL）
  String get type;  // 类型标识（album/playlist）
  Map<String, dynamic> toJson();  // 序列化方法
}

// 专辑特有属性
abstract class AlbumCollection extends Collection {
  DateTime? get releaseDate;
  List<String>? get artists;
}

// 播放列表特有属性
abstract class PlaylistCollection extends Collection {
  String? get owner;
  bool get isPublic;
  bool get collaborative;
  int get totalTracks;
}

enum CollectionType {
  album,
  playlist
}