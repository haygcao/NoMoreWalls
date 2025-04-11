import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/models/media_model.dart';

/// Implementation of AlbumInterface that provides album-specific functionality
class AlbumModel extends MediaModel implements AlbumInterface {
  @override
  final List<ArtistInterface> artists;

  @override
  final List<TrackInterface> tracks;

  @override
  final DateTime releaseDate;

  @override
  final int totalTracks;

  @override
  final String albumType;

  @override
  final String? label;

  @override
  final List<String> genres;

  @override
  final bool isAvailable;

  @override
  final String? copyrightText;

  const AlbumModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.duration,
    super.metadata = const {},
    required this.artists,
    this.tracks = const [],
    required this.releaseDate,
    required this.totalTracks,
    required this.albumType,
    this.label,
    this.genres = const [],
    this.isAvailable = true,
    this.copyrightText,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'releaseDate': releaseDate.toIso8601String(),
      'totalTracks': totalTracks,
      'albumType': albumType,
      'label': label,
      'genres': genres,
      'isAvailable': isAvailable,
      'copyrightText': copyrightText,
    };
  }

  @override
  AlbumModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? duration,
    Map<String, dynamic>? metadata,
    List<ArtistInterface>? artists,
    List<TrackInterface>? tracks,
    DateTime? releaseDate,
    int? totalTracks,
    String? albumType,
    String? label,
    List<String>? genres,
    bool? isAvailable,
    String? copyrightText,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      artists: artists ?? this.artists,
      tracks: tracks ?? this.tracks,
      releaseDate: releaseDate ?? this.releaseDate,
      totalTracks: totalTracks ?? this.totalTracks,
      albumType: albumType ?? this.albumType,
      label: label ?? this.label,
      genres: genres ?? this.genres,
      isAvailable: isAvailable ?? this.isAvailable,
      copyrightText: copyrightText ?? this.copyrightText,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AlbumModel &&
          runtimeType == other.runtimeType &&
          artists == other.artists &&
          tracks == other.tracks &&
          releaseDate == other.releaseDate &&
          totalTracks == other.totalTracks &&
          albumType == other.albumType &&
          isAvailable == other.isAvailable;

  @override
  int get hashCode =>
      super.hashCode ^
      artists.hashCode ^
      tracks.hashCode ^
      releaseDate.hashCode ^
      totalTracks.hashCode ^
      albumType.hashCode ^
      isAvailable.hashCode;
}
