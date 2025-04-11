import 'package:flutter/foundation.dart';
import '../interfaces/media/album_interface.dart';
import 'media_model.dart';

/// Model class for albums
///
/// Implements the AlbumInterface and extends MediaModel
@immutable
class AlbumModel extends MediaModel implements AlbumInterface {
  /// List of artist IDs associated with this album
  final List<String> artistIds;

  /// List of artist names associated with this album
  final List<String> artistNames;

  /// Release date of the album
  final DateTime? releaseDate;

  /// Total number of tracks in the album
  final int totalTracks;

  /// Album type (album, single, compilation, etc.)
  final String? albumType;

  /// Genres associated with this album
  final List<String>? genres;

  /// Popularity score (0-100)
  final int? popularity;

  /// Platform-specific metadata
  final Map<String, dynamic> platformMetadata;

  /// Create a new album model
  const AlbumModel({
    required super.id,
    required super.platform,
    required super.name,
    super.imageUrl,
    required this.artistIds,
    required this.artistNames,
    this.releaseDate,
    required this.totalTracks,
    this.albumType,
    this.genres,
    this.popularity,
    this.platformMetadata = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'artistIds': artistIds,
        'artistNames': artistNames,
        'releaseDate': releaseDate?.toIso8601String(),
        'totalTracks': totalTracks,
        'albumType': albumType,
        'genres': genres,
        'popularity': popularity,
        'platformMetadata': platformMetadata,
      };

  @override
  AlbumModel copyWith({
    String? id,
    String? platform,
    String? name,
    String? imageUrl,
    List<String>? artistIds,
    List<String>? artistNames,
    DateTime? releaseDate,
    int? totalTracks,
    String? albumType,
    List<String>? genres,
    int? popularity,
    Map<String, dynamic>? platformMetadata,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      artistIds: artistIds ?? this.artistIds,
      artistNames: artistNames ?? this.artistNames,
      releaseDate: releaseDate ?? this.releaseDate,
      totalTracks: totalTracks ?? this.totalTracks,
      albumType: albumType ?? this.albumType,
      genres: genres ?? this.genres,
      popularity: popularity ?? this.popularity,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AlbumModel &&
          runtimeType == other.runtimeType &&
          artistIds == other.artistIds &&
          artistNames == other.artistNames &&
          releaseDate == other.releaseDate &&
          totalTracks == other.totalTracks &&
          albumType == other.albumType &&
          genres == other.genres &&
          popularity == other.popularity;

  @override
  int get hashCode =>
      super.hashCode ^
      artistIds.hashCode ^
      artistNames.hashCode ^
      releaseDate.hashCode ^
      totalTracks.hashCode ^
      albumType.hashCode ^
      genres.hashCode ^
      popularity.hashCode;
}
