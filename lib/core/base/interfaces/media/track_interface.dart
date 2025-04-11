import 'package:flutter/foundation.dart';
import 'media_interface.dart';

/// Interface for track media type
///
/// Defines the properties and methods specific to music tracks
@immutable
abstract class TrackInterface extends MediaInterface {
  /// List of artist IDs associated with this track
  List<String> get artistIds;

  /// List of artist names associated with this track
  List<String> get artistNames;

  /// Album ID this track belongs to
  String? get albumId;

  /// Album name this track belongs to
  String? get albumName;

  /// Duration of the track in milliseconds
  int get durationMs;

  /// Whether this track is playable
  bool get isPlayable;

  /// Track number in the album
  int? get trackNumber;

  /// Disc number in the album
  int? get discNumber;

  /// Popularity score (0-100)
  int? get popularity;

  /// Whether this track is explicit
  bool get isExplicit;

  /// Preview URL for the track (if available)
  String? get previewUrl;

  /// Platform-specific metadata
  Map<String, dynamic> get platformMetadata;
}
