import 'package:flutter/foundation.dart';
import '../interfaces/media/track_interface.dart';
import 'media_model.dart';

/// Model class for tracks
///
/// Implements the TrackInterface and extends MediaModel
@immutable
class TrackModel extends MediaModel implements TrackInterface {
  /// List of artist IDs associated with this track
  final List<String> artistIds;

  /// List of artist names associated with this track
  final List<String> artistNames;

  /// Album ID this track belongs to
  final String? albumId;

  /// Album name this track belongs to
  final String? albumName;

  /// Duration of the track in milliseconds
  final int durationMs;

  /// Whether this track is playable
  final bool isPlayable;

  /// Track number in the album
  final int? trackNumber;

  /// Disc number in the album
  final int? discNumber;

  /// Popularity score (0-100)
  final int? popularity;

  /// Whether this track is explicit
  final bool isExplicit;

  /// Preview URL for the track (if available)
  final String? previewUrl;

  /// Platform-specific metadata
  final Map<String, dynamic> platformMetadata;

  /// Create a new track model
  const TrackModel({
    required super.id,
    required super.platform,
    required super.name,
    super.imageUrl,
    required this.artistIds,
    required this.artistNames,
    this.albumId,
    this.albumName,
    required this.durationMs,
    this.isPlayable = true,
    this.trackNumber,
    this.discNumber,
    this.popularity,
    this.isExplicit = false,
    this.previewUrl,
    this.platformMetadata = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'artistIds': artistIds,
        'artistNames': artistNames,
        'albumId': albumId,
        'albumName': albumName,
        'durationMs': durationMs,
        'isPlayable': isPlayable,
        'trackNumber': trackNumber,
        'discNumber': discNumber,
        'popularity': popularity,
        'isExplicit': isExplicit,
        'previewUrl': previewUrl,
        'platformMetadata': platformMetadata,
      };

  @override
  TrackModel copyWith({
    String? id,
    String? platform,
    String? name,
    String? imageUrl,
    List<String>? artistIds,
    List<String>? artistNames,
    String? albumId,
    String? albumName,
    int? durationMs,
    bool? isPlayable,
    int? trackNumber,
    int? discNumber,
    int? popularity,
    bool? isExplicit,
    String? previewUrl,
    Map<String, dynamic>? platformMetadata,
  }) {
    return TrackModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      artistIds: artistIds ?? this.artistIds,
      artistNames: artistNames ?? this.artistNames,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      durationMs: durationMs ?? this.durationMs,
      isPlayable: isPlayable ?? this.isPlayable,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      popularity: popularity ?? this.popularity,
      isExplicit: isExplicit ?? this.isExplicit,
      previewUrl: previewUrl ?? this.previewUrl,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TrackModel &&
          runtimeType == other.runtimeType &&
          artistIds == other.artistIds &&
          artistNames == other.artistNames &&
          albumId == other.albumId &&
          albumName == other.albumName &&
          durationMs == other.durationMs &&
          isPlayable == other.isPlayable &&
          trackNumber == other.trackNumber &&
          discNumber == other.discNumber &&
          popularity == other.popularity &&
          isExplicit == other.isExplicit &&
          previewUrl == other.previewUrl;

  @override
  int get hashCode =>
      super.hashCode ^
      artistIds.hashCode ^
      artistNames.hashCode ^
      albumId.hashCode ^
      albumName.hashCode ^
      durationMs.hashCode ^
      isPlayable.hashCode ^
      trackNumber.hashCode ^
      discNumber.hashCode ^
      popularity.hashCode ^
      isExplicit.hashCode ^
      previewUrl.hashCode;
}
