import 'package:spotube/services/base/base_track.dart';

abstract class SourceableTrack extends BaseTrack {
  @override
  String get id;
  
  @override
  String get title;
  
  @override
  String get artistName;
  
  @override
  String? get albumName;
  
  @override
  Duration get duration;
  
  String? get thumbnailUrl;
  String? get artistId;
  String? get albumId;
  
  @override
  Map<String, dynamic> toJson();
  
  String getSearchTerm() {
    return "$title - $artistName";
  }
  
  // 其余方法保持不变
  Map<String, dynamic> toMediaItem() {
    return {
      'id': id,
      'title': title,
      'artist': artistName,
      'album': albumName,
      'duration': duration.inMilliseconds,
      'artUri': thumbnailUrl,
    };
  }
  
  String getDisplayName() {
    return "$title - $artistName";
  }
  
  String getDescription() {
    return albumName != null ? "专辑: $albumName" : "";
  }
}