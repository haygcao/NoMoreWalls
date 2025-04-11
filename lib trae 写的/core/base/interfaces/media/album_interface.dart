import 'media_interface.dart';
import 'artist_interface.dart';
import 'track_interface.dart';

/// Interface defining the structure for album objects
abstract class AlbumInterface implements MediaInterface {
  /// List of artists associated with the album
  List<ArtistInterface> get artists;

  /// List of tracks in the album
  List<TrackInterface> get tracks;

  /// Release date of the album
  DateTime get releaseDate;

  /// Total number of tracks in the album
  int get totalTracks;

  /// Album type (e.g., album, single, compilation)
  String get albumType;

  /// Label that released the album
  String? get label;

  /// Genres associated with the album
  List<String> get genres;

  /// Whether the album is currently available
  bool get isAvailable;

  /// Copyright text for the album
  String? get copyrightText;

  @override
  Map<String, dynamic> toJson();

  @override
  AlbumInterface copyWith();
}
