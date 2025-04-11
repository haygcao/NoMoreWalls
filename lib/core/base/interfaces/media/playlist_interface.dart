import 'package:flutter/foundation.dart';
import 'media_interface.dart';

/// Interface for playlist media type
///
/// Defines the properties and methods specific to music playlists
@immutable
abstract class PlaylistInterface extends MediaInterface {
  /// Description of the playlist
  String? get description;

  /// Owner ID of the playlist
  String? get ownerId;

  /// Owner name/display name of the playlist
  String? get ownerName;

  /// Whether this playlist is public
  bool get isPublic;

  /// Whether this playlist is collaborative
  bool get isCollaborative;

  /// Total number of tracks in the playlist
  int get totalTracks;

  /// Platform-specific metadata
  Map<String, dynamic> get platformMetadata;
}
