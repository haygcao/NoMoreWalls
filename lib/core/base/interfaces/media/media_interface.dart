import 'package:flutter/foundation.dart';

/// Base interface for all media types in the application
///
/// This interface defines the common properties and methods that all media types
/// (tracks, albums, artists, playlists) should implement.
@immutable
abstract class MediaInterface {
  /// Unique identifier for the media
  String get id;

  /// Name or title of the media
  String get name;

  /// URL to the media's image/thumbnail
  String? get imageUrl;

  /// Platform source of this media (e.g., "spotify", "youtube_music")
  String get platform;

  /// Convert the media to a JSON representation
  Map<String, dynamic> toJson();
}
