/// Cache keys for the application
///
/// Contains constants for all cache keys used in the application
class CacheKeys {
  // Auth related keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userProfile = 'user_profile';

  // Media related keys
  static const String featuredPlaylists = 'featured_playlists';
  static const String newReleases = 'new_releases';
  static const String recommendedTracks = 'recommended_tracks';
  static const String topArtists = 'top_artists';

  // Track related keys
  static const String trackPrefix = 'track_';
  static const String trackLyrics = 'track_lyrics_';
  static const String trackAudioFeatures = 'track_audio_features_';

  // Album related keys
  static const String albumPrefix = 'album_';
  static const String albumTracks = 'album_tracks_';

  // Artist related keys
  static const String artistPrefix = 'artist_';
  static const String artistTopTracks = 'artist_top_tracks_';
  static const String artistAlbums = 'artist_albums_';
  static const String artistRelated = 'artist_related_';

  // Playlist related keys
  static const String playlistPrefix = 'playlist_';
  static const String playlistTracks = 'playlist_tracks_';
  static const String userPlaylists = 'user_playlists';

  // Search related keys
  static const String searchResults = 'search_results_';

  // Settings related keys
  static const String appSettings = 'app_settings';
  static const String playerSettings = 'player_settings';

  // Private constructor to prevent instantiation
  CacheKeys._();

  /// Generate a cache key for a track
  static String trackKey(String trackId, String platform) =>
      '$trackPrefix${platform}_$trackId';

  /// Generate a cache key for an album
  static String albumKey(String albumId, String platform) =>
      '$albumPrefix${platform}_$albumId';

  /// Generate a cache key for an artist
  static String artistKey(String artistId, String platform) =>
      '$artistPrefix${platform}_$artistId';

  /// Generate a cache key for a playlist
  static String playlistKey(String playlistId, String platform) =>
      '$playlistPrefix${platform}_$playlistId';

  /// Generate a cache key for search results
  static String searchKey(String query, String type, String platform) =>
      '$searchResults${platform}_${type}_$query';
}
