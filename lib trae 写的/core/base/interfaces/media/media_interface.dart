/// Media interface that defines the basic structure for all media types
abstract class MediaInterface {
  /// Unique identifier for the media item
  String get id;

  /// Name or title of the media item
  String get name;

  /// URL to the media item's artwork/image
  String? get imageUrl;

  /// Duration of the media in milliseconds (if applicable)
  int? get duration;

  /// Additional metadata as key-value pairs
  Map<String, dynamic> get metadata;

  /// Convert the media item to a JSON representation
  Map<String, dynamic> toJson();

  /// Create a copy of the media item with optional parameter overrides
  MediaInterface copyWith();
}
