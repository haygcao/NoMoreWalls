import 'package:flutter/foundation.dart';
import 'media_interface.dart';

/// Interface for album media type
///
/// Defines the properties and methods specific to music albums
@immutable
abstract class AlbumInterface extends MediaInterface {
  /// List of artist IDs associated with this album
  List<String> get artistIds;

  /// List of artist names associated with this album
  List<String> get artistNames;

  /// Release date of the album
  DateTime? get releaseDate;

  /// Total number of tracks in the album
  int get totalTracks;

  /// Album type (album, single, compilation, etc.)
  String? get albumType;

  /// Genres associated with this album
  List<String>? get genres;

  /// Popularity score (0-100)
  int? get popularity;

  /// Platform-specific metadata
  Map<String, dynamic> get platformMetadata;
}
