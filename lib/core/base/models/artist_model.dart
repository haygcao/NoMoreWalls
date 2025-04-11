import 'package:flutter/foundation.dart';
import '../interfaces/media/artist_interface.dart';
import 'media_model.dart';

/// Model class for artists
///
/// Implements the ArtistInterface and extends MediaModel
@immutable
class ArtistModel extends MediaModel implements ArtistInterface {
  /// Genres associated with this artist
  final List<String>? genres;

  /// Popularity score (0-100)
  final int? popularity;

  /// Number of followers
  final int? followersCount;

  /// Artist description or biography
  final String? description;

  /// Platform-specific metadata
  final Map<String, dynamic> platformMetadata;

  /// Create a new artist model
  const ArtistModel({
    required super.id,
    required super.platform,
    required super.name,
    super.imageUrl,
    this.genres,
    this.popularity,
    this.followersCount,
    this.description,
    this.platformMetadata = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'genres': genres,
        'popularity': popularity,
        'followersCount': followersCount,
        'description': description,
        'platformMetadata': platformMetadata,
      };

  @override
  ArtistModel copyWith({
    String? id,
    String? platform,
    String? name,
    String? imageUrl,
    List<String>? genres,
    int? popularity,
    int? followersCount,
    String? description,
    Map<String, dynamic>? platformMetadata,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      genres: genres ?? this.genres,
      popularity: popularity ?? this.popularity,
      followersCount: followersCount ?? this.followersCount,
      description: description ?? this.description,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ArtistModel &&
          runtimeType == other.runtimeType &&
          genres == other.genres &&
          popularity == other.popularity &&
          followersCount == other.followersCount &&
          description == other.description;

  @override
  int get hashCode =>
      super.hashCode ^
      genres.hashCode ^
      popularity.hashCode ^
      followersCount.hashCode ^
      description.hashCode;
}
