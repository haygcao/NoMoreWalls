import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotube/models/youtube_music/album.dart';
import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/models/youtube_music/channel.dart';

class YoutubeMusicSearchResults {
  final List<YoutubeMusicTrack> tracks;
  final List<YoutubeMusicAlbum> albums;
  final List<YoutubeMusicPlaylist> playlists;
  final List<YoutubeMusicChannel> artists;

  const YoutubeMusicSearchResults({
    required this.tracks,
    required this.albums,
    required this.playlists,
    required this.artists,
  });

  factory YoutubeMusicSearchResults.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicSearchResults(
      tracks: (json['tracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
      albums: (json['albums'] as List)
          .map((album) => YoutubeMusicAlbum.fromJson(album))
          .toList(),
      playlists: (json['playlists'] as List)
          .map((playlist) => YoutubeMusicPlaylist.fromJson(playlist))
          .toList(),
      artists: (json['artists'] as List)
          .map((artist) => YoutubeMusicChannel.fromJson(artist))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tracks': tracks.map((track) => track.toJson()).toList(),
    'albums': albums.map((album) => album.toJson()).toList(),
    'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
    'artists': artists.map((artist) => artist.toJson()).toList(),
  };
}