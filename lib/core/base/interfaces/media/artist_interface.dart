import 'package:flutter/foundation.dart';
import 'media_interface.dart';

/// Interface for artist media type
///
/// Defines the properties and methods specific to music artists
@immutable
abstract class ArtistInterface extends MediaInterface {
  /// Genres associated with this artist
  List<String>? get genres;

  /// Popularity score (0-100)
  int? get popularity;

  /// Number of followers
  int? get followersCount;

  /// Artist description or biography
  String? get description;

  /// Platform-specific metadata
  Map<String, dynamic> get platformMetadata;
}
