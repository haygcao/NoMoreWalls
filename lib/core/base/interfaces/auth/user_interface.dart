import '../media/playlist_interface.dart';
import '../media/track_interface.dart';
import '../media/artist_interface.dart';

/// Interface defining the structure for user objects
abstract class UserInterface {
  /// Unique identifier for the user
  String get id;

  /// Display name of the user
  String get displayName;

  /// Email address of the user
  String? get email;

  /// URL to the user's profile image
  String? get imageUrl;

  /// User's subscription type/plan
  String get subscriptionType;

  /// Whether the user's email is verified
  bool get isEmailVerified;

  /// User's country code
  String get country;

  /// User's preferred language
  String get language;

  /// User's playlists
  List<PlaylistInterface> get playlists;

  /// User's saved/liked tracks
  List<TrackInterface> get likedTracks;

  /// User's followed artists
  List<ArtistInterface> get followedArtists;

  /// External URLs associated with the user (social media profiles etc.)
  Map<String, String> get externalUrls;

  /// Update user profile information
  Future<void> updateProfile({
    String? displayName,
    String? imageUrl,
  });

  /// Change user's password
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Delete user account
  Future<void> deleteAccount(String password);

  /// Convert the user object to a JSON representation
  Map<String, dynamic> toJson();

  /// Create a copy of the user object with optional parameter overrides
  UserInterface copyWith();
}
