
import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/base/media_base.dart';

abstract class MusicService {
  Future<List<BaseTrack>> searchTracks(String query);
  Future<List<MediaBase>> searchAlbums(String query);
  Future<List<MediaBase>> searchArtists(String query);
  Future<List<MediaBase>> searchPlaylists(String query);
  
  Future<List<BaseTrack>> getPlaylistTracks(String playlistId);
  Future<List<BaseTrack>> getAlbumTracks(String albumId);
  Future<List<MediaBase>> getArtistAlbums(String artistId);
  Future<List<BaseTrack>> getArtistTopTracks(String artistId);
}