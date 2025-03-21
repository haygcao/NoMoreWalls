import 'package:spotube/services/base/sourceable_track.dart';

abstract class PlaylistBase {
  String get id;
  String get name;
  String? get description;
  String? get imageUrl;
  String? get owner;
  bool get isPublic;
  bool get collaborative;
  int get totalTracks;
  Map<String, dynamic> toJson();
}

// 基础接口定义
abstract class ArtistBase {
  String get id;
  String get name;
  String? get imageUrl;
  String? get description;
  Map<String, dynamic> toJson();
}

abstract class AlbumBase {
  String get id;
  String get name;
  String? get imageUrl;
  List<String>? get artists;
  DateTime? get releaseDate;
  String? get albumType;
  List<SourceableTrack>? get tracks; // 添加 tracks 属性
  Map<String, dynamic> toJson();
}


