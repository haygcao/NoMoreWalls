abstract class MediaCollection {
  String get id;
  String get name;
  String? get description;
  String? get imageUrl;
  MediaCollectionType get type;
}

enum MediaCollectionType {
  album,
  playlist,
}