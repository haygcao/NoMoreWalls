import 'package:flutter/foundation.dart';
import '../interfaces/media/playlist_interface.dart';
import 'media_model.dart';

/// Model class for playlists
///
/// Implements the PlaylistInterface and extends MediaModel
@immutable
class PlaylistModel extends MediaModel implements PlaylistInterface {
  /// Description of the playlist
  final String? description;

  /// Owner ID of the playlist
  final String? ownerId;

  /// Owner name/display name of the playlist
  final String? ownerName;

  /// Whether this playlist is public
  final bool isPublic;

  /// Whether this playlist is collaborative
  final bool isCollaborative;

  /// Total number of tracks in the playlist
  final int totalTracks;

  /// Platform-specific metadata
  final Map<String, dynamic> platformMetadata;

  /// Create a new playlist model
  const PlaylistModel({
    required super.id,
    required super.platform,
    required super.name,
    super.imageUrl,
    this.description,
    this.ownerId,
    this.ownerName,
    this.isPublic = true,
    this.isCollaborative = false,
    required this.totalTracks,
    this.platformMetadata = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'description': description,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'isPublic': isPublic,
        'isCollaborative': isCollaborative,
        'totalTracks': totalTracks,
        'platformMetadata': platformMetadata,
      };

  @override
  PlaylistModel copyWith({
    String? id,
    String? platform,
    String? name,
    String? imageUrl,
    String? description,
    String? ownerId,
    String? ownerName,
    bool? isPublic,
    bool? isCollaborative,
    int? totalTracks,
    Map<String, dynamic>? platformMetadata,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      isPublic: isPublic ?? this.isPublic,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      totalTracks: totalTracks ?? this.totalTracks,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is PlaylistModel &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          ownerId == other.ownerId &&
          ownerName == other.ownerName &&
          isPublic == other.isPublic &&
          isCollaborative == other.isCollaborative &&
          totalTracks == other.totalTracks;

  @override
  int get hashCode =>
      super.hashCode ^
      description.hashCode ^
      ownerId.hashCode ^
      ownerName.hashCode ^
      isPublic.hashCode ^
      isCollaborative.hashCode ^
      totalTracks.hashCode;
}
