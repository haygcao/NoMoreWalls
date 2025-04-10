import 'package:spotube/models/youtube_music/track.dart';

class YoutubeMusicAlbum {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String artistId;
  final String artistName;
  final DateTime releaseDate;
  final List<YoutubeMusicTrack> tracks;

  const YoutubeMusicAlbum({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.artistId,
    required this.artistName,
    required this.releaseDate,
    required this.tracks,
    this.description,
  });

  factory YoutubeMusicAlbum.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicAlbum(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      artistId: json['artistId'],
      artistName: json['artistName'],
      releaseDate: DateTime.parse(json['releaseDate']),
      tracks: (json['tracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    'thumbnailUrl': thumbnailUrl,
    'artistId': artistId,
    'artistName': artistName,
    'releaseDate': releaseDate.toIso8601String(),
    'tracks': tracks.map((track) => track.toJson()).toList(),
  };
}