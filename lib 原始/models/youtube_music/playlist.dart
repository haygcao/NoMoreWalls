import 'package:spotube/models/youtube_music/track.dart';

class YoutubeMusicPlaylist {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String authorId;
  final String authorName;
  final List<YoutubeMusicTrack> tracks;
  final int trackCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const YoutubeMusicPlaylist({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.tracks,
    required this.trackCount,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory YoutubeMusicPlaylist.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicPlaylist(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      tracks: (json['tracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
      trackCount: json['trackCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    'thumbnailUrl': thumbnailUrl,
    'authorId': authorId,
    'authorName': authorName,
    'tracks': tracks.map((track) => track.toJson()).toList(),
    'trackCount': trackCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}