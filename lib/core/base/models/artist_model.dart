import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/models/media_model.dart';

/// Implementation of ArtistInterface that provides artist-specific functionality
class ArtistModel extends MediaModel implements ArtistInterface {
  @override
  final List<String> genres;

  @override
  final int followers;

  @override
  final int popularity;

  @override
  final List<TrackInterface> topTracks;

  @override
  final List<AlbumInterface> albums;

  @override
  final String? biography;

  @override
  final Map<String, String> externalUrls;

  @override
  final bool isFollowed;

  const ArtistModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.duration,
    super.metadata = const {},
    this.genres = const [],
    this.followers = 0,
    this.popularity = 0,
    this.topTracks = const [],
    this.albums = const [],
    this.biography,
    this.externalUrls = const {},
    this.isFollowed = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'genres': genres,
      'followers': followers,
      'popularity': popularity,
      'topTracks': topTracks.map((track) => track.toJson()).toList(),
      'albums': albums.map((album) => album.toJson()).toList(),
      'biography': biography,
      'externalUrls': externalUrls,
      'isFollowed': isFollowed,
    };
  }

  @override
  ArtistModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? duration,
    Map<String, dynamic>? metadata,
    List<String>? genres,
    int? followers,
    int? popularity,
    List<TrackInterface>? topTracks,
    List<AlbumInterface>? albums,
    String? biography,
    Map<String, String>? externalUrls,
    bool? isFollowed,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      genres: genres ?? this.genres,
      followers: followers ?? this.followers,
      popularity: popularity ?? this.popularity,
      topTracks: topTracks ?? this.topTracks,
      albums: albums ?? this.albums,
      biography: biography ?? this.biography,
      externalUrls: externalUrls ?? this.externalUrls,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ArtistModel &&
          runtimeType == other.runtimeType &&
          genres == other.genres &&
          followers == other.followers &&
          popularity == other.popularity &&
          isFollowed == other.isFollowed;

  @override
  int get hashCode =>
      super.hashCode ^
      genres.hashCode ^
      followers.hashCode ^
      popularity.hashCode ^
      isFollowed.hashCode;
}
