import 'media_interface.dart';
import 'album_interface.dart';
import 'track_interface.dart';

/// Interface defining the structure for artist objects
abstract class ArtistInterface implements MediaInterface {
  /// List of genres associated with the artist
  List<String> get genres;

  /// Number of followers/subscribers
  int get followers;

  /// Artist's popularity rating (0-100)
  int get popularity;

  /// Top tracks by the artist
  List<TrackInterface> get topTracks;

  /// Albums released by the artist
  List<AlbumInterface> get albums;

  /// Brief biography or description of the artist
  String? get biography;

  /// External URLs associated with the artist (social media, website, etc.)
  Map<String, String> get externalUrls;

  /// Whether the artist is currently being followed by the user
  bool get isFollowed;

  @override
  Map<String, dynamic> toJson();

  @override
  ArtistInterface copyWith();
}
