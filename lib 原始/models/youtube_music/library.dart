import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/models/youtube_music/album.dart';
import 'package:spotube/models/youtube_music/track.dart';

class YoutubeMusicLibrary {
  final List<YoutubeMusicPlaylist> playlists;
  final List<YoutubeMusicAlbum> albums;
  final List<YoutubeMusicTrack> likedTracks;

  const YoutubeMusicLibrary({
    required this.playlists,
    required this.albums,
    required this.likedTracks,
  });

  factory YoutubeMusicLibrary.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicLibrary(
      playlists: (json['playlists'] as List)
          .map((playlist) => YoutubeMusicPlaylist.fromJson(playlist))
          .toList(),
      albums: (json['albums'] as List)
          .map((album) => YoutubeMusicAlbum.fromJson(album))
          .toList(),
      likedTracks: (json['likedTracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
    'albums': albums.map((album) => album.toJson()).toList(),
    'likedTracks': likedTracks.map((track) => track.toJson()).toList(),
  };
}