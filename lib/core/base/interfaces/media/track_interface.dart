import 'media_interface.dart';
import 'artist_interface.dart';
import 'album_interface.dart';

/// Interface defining the structure for track objects
abstract class TrackInterface implements MediaInterface {
  /// List of artists performing the track
  List<ArtistInterface> get artists;

  /// Album containing this track
  AlbumInterface? get album;

  /// Track number in the album
  int? get trackNumber;

  /// Disc number in the album
  int? get discNumber;

  /// Whether the track is explicit
  bool get isExplicit;

  /// Whether the track is playable in the user's region
  bool get isPlayable;

  /// Whether the track is currently liked/saved by the user
  bool get isLiked;

  /// Preview URL for the track (30s sample)
  String? get previewUrl;

  /// URLs for different quality audio streams
  Map<String, String> get audioUrls;

  /// Popularity rating of the track (0-100)
  int get popularity;

  /// Whether the track is currently downloaded
  bool get isDownloaded;

  /// Local file path if the track is downloaded
  String? get localFilePath;

  /// Start playing the track
  Future<void> play();

  /// Pause the current playback
  Future<void> pause();

  /// Stop the current playback
  Future<void> stop();

  /// Download the track
  Future<void> download();

  /// Delete the downloaded track
  Future<void> deleteDownload();

  @override
  Map<String, dynamic> toJson();

  @override
  TrackInterface copyWith();
}
