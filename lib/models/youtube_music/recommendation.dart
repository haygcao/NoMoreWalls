import 'package:spotube/models/youtube_music/channel.dart';
import 'package:spotube/models/youtube_music/track.dart';

class YoutubeMusicRecommendation {
  final String id;
  final String title;
  final String thumbnailUrl;
  final List<YoutubeMusicTrack> tracks;
  final String type; // 'mix', 'playlist', 'radio'
  final String? description;
  final DateTime createdAt;

  const YoutubeMusicRecommendation({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.tracks,
    required this.type,
    required this.createdAt,
    this.description,
  });

  factory YoutubeMusicRecommendation.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicRecommendation(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      tracks: (json['tracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
      type: json['type'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'thumbnailUrl': thumbnailUrl,
    'tracks': tracks.map((track) => track.toJson()).toList(),
    'type': type,
    if (description != null) 'description': description,
    'createdAt': createdAt.toIso8601String(),
  };
}

class YoutubeMusicMix extends YoutubeMusicRecommendation {
  final String mood; // 'energetic', 'chill', 'focus', etc.
  final String? genre;

  const YoutubeMusicMix({
    required super.id,
    required super.title,
    required super.thumbnailUrl,
    required super.tracks,
    required this.mood,
    required super.createdAt,
    super.description,
    this.genre,
  }) : super(type: 'mix');

  factory YoutubeMusicMix.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicMix(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      tracks: (json['tracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
      mood: json['mood'],
      genre: json['genre'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'mood': mood,
    if (genre != null) 'genre': genre,
  };
}

class YoutubeMusicRadio extends YoutubeMusicRecommendation {
  final YoutubeMusicTrack seedTrack;
  final YoutubeMusicChannel seedChannel;

  const YoutubeMusicRadio({
    required super.id,
    required super.title,
    required super.thumbnailUrl,
    required super.tracks,
    required this.seedTrack,
    required this.seedChannel,
    required super.createdAt,
    super.description,
  }) : super(type: 'radio');

  factory YoutubeMusicRadio.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicRadio(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      tracks: (json['tracks'] as List)
          .map((track) => YoutubeMusicTrack.fromJson(track))
          .toList(),
      seedTrack: YoutubeMusicTrack.fromJson(json['seedTrack']),
      seedChannel: YoutubeMusicChannel.fromJson(json['seedChannel']),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'seedTrack': seedTrack.toJson(),
    'seedChannel': seedChannel.toJson(),
  };
}