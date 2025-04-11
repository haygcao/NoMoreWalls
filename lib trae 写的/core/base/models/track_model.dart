import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/models/media_model.dart';

/// Implementation of TrackInterface that provides track-specific functionality
class TrackModel extends MediaModel implements TrackInterface {
  @override
  final List<ArtistInterface> artists;

  @override
  final AlbumInterface? album;

  @override
  final int? trackNumber;

  @override
  final int? discNumber;

  @override
  final bool isExplicit;

  @override
  final bool isPlayable;

  @override
  final bool isLiked;

  @override
  final String? previewUrl;

  @override
  final Map<String, String> audioUrls;

  @override
  final int popularity;

  @override
  final bool isDownloaded;

  @override
  final String? localFilePath;

  const TrackModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.duration,
    super.metadata = const {},
    required this.artists,
    this.album,
    this.trackNumber,
    this.discNumber,
    this.isExplicit = false,
    this.isPlayable = true,
    this.isLiked = false,
    this.previewUrl,
    this.audioUrls = const {},
    this.popularity = 0,
    this.isDownloaded = false,
    this.localFilePath,
  });

  @override
  Future<void> play() async {
    // Implementation will be provided by the PlaybackService
  }

  @override
  Future<void> pause() async {
    // Implementation will be provided by the PlaybackService
  }

  @override
  Future<void> stop() async {
    // Implementation will be provided by the PlaybackService
  }

  @override
  Future<void> download() async {
    // Implementation will be provided by the DownloadService
  }

  @override
  Future<void> deleteDownload() async {
    // Implementation will be provided by the DownloadService
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'artists': artists.map((artist) => artist.toJson()).toList(),
      'album': album?.toJson(),
      'trackNumber': trackNumber,
      'discNumber': discNumber,
      'isExplicit': isExplicit,
      'isPlayable': isPlayable,
      'isLiked': isLiked,
      'previewUrl': previewUrl,
      'audioUrls': audioUrls,
      'popularity': popularity,
      'isDownloaded': isDownloaded,
      'localFilePath': localFilePath,
    };
  }

  @override
  TrackModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? duration,
    Map<String, dynamic>? metadata,
    List<ArtistInterface>? artists,
    AlbumInterface? album,
    int? trackNumber,
    int? discNumber,
    bool? isExplicit,
    bool? isPlayable,
    bool? isLiked,
    String? previewUrl,
    Map<String, String>? audioUrls,
    int? popularity,
    bool? isDownloaded,
    String? localFilePath,
  }) {
    return TrackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      isExplicit: isExplicit ?? this.isExplicit,
      isPlayable: isPlayable ?? this.isPlayable,
      isLiked: isLiked ?? this.isLiked,
      previewUrl: previewUrl ?? this.previewUrl,
      audioUrls: audioUrls ?? this.audioUrls,
      popularity: popularity ?? this.popularity,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TrackModel &&
          runtimeType == other.runtimeType &&
          artists == other.artists &&
          album == other.album &&
          trackNumber == other.trackNumber &&
          discNumber == other.discNumber &&
          isExplicit == other.isExplicit &&
          isPlayable == other.isPlayable &&
          isLiked == other.isLiked;

  @override
  int get hashCode =>
      super.hashCode ^
      artists.hashCode ^
      album.hashCode ^
      trackNumber.hashCode ^
      discNumber.hashCode ^
      isExplicit.hashCode ^
      isPlayable.hashCode ^
      isLiked.hashCode;
}
