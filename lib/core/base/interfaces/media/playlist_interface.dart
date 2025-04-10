import 'media_interface.dart';
import 'track_interface.dart';
import '../auth/user_interface.dart';

/// Interface defining the structure for playlist objects
abstract class PlaylistInterface implements MediaInterface {
  /// Owner of the playlist
  UserInterface get owner;

  /// Description of the playlist
  String? get description;

  /// Whether the playlist is public
  bool get isPublic;

  /// Whether the playlist is collaborative
  bool get isCollaborative;

  /// Number of followers
  int get followers;

  /// List of tracks in the playlist
  List<TrackInterface> get tracks;

  /// Total number of tracks
  int get totalTracks;

  /// Whether the current user follows this playlist
  bool get isFollowed;

  /// Add tracks to the playlist
  Future<void> addTracks(List<TrackInterface> tracks);

  /// Remove tracks from the playlist
  Future<void> removeTracks(List<TrackInterface> tracks);

  /// Reorder tracks in the playlist
  Future<void> reorderTracks(int oldIndex, int newIndex);

  /// Update playlist details (name, description, public status)
  Future<void> update({
    String? name,
    String? description,
    bool? isPublic,
    bool? isCollaborative,
  });

  @override
  Map<String, dynamic> toJson();

  @override
  PlaylistInterface copyWith();
}
