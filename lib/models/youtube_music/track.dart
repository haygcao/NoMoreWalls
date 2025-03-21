import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class YoutubeMusicTrack implements BaseTrack, SourceableTrack {
  @override
  final String id;
  @override
  final String title;
  final String? description;
  @override
  final String thumbnailUrl;
  @override
  final Duration duration;
  final String channelId;
  final String channelName;
  final int viewCount;
  final DateTime publishedAt;
  final List<String> tags;
  @override
  final String artistId;
  @override
  final String artistName;
  @override
  final String? albumId;
  @override
  final String? albumName;
  
  const YoutubeMusicTrack({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.channelId,
    required this.channelName,
    required this.viewCount,
    required this.publishedAt,
    required this.artistId,
    required this.artistName,
    this.description,
    this.tags = const [],
    this.albumId,
    this.albumName,
  });
  @override
  String getSearchTerm() {
    final cleanTitle = title.replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), '').trim();
    return "$cleanTitle - $artistName";
  }
  factory YoutubeMusicTrack.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicTrack(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: Duration(seconds: json['duration']),
      channelId: json['channelId'],
      channelName: json['channelName'],
      viewCount: json['viewCount'],
      publishedAt: DateTime.parse(json['publishedAt']),
      artistId: json['artistId'],
      artistName: json['artistName'],
      tags: List<String>.from(json['tags'] ?? []),
      albumId: json['albumId'],
      albumName: json['albumName'],
    );
  }
  @override
  String getDisplayName() {
    return "$title - $artistName";
  }
  @override
  String getDescription() {
    return albumName != null ? "专辑: $albumName" : channelName;
  }
  @override
  Map<String, dynamic> toMediaItem() {
    return {
      'id': id,
      'title': title,
      'artist': artistName,
      'album': albumName,
      'duration': duration.inMilliseconds,
      'artUri': thumbnailUrl,
    };
  }
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    'thumbnailUrl': thumbnailUrl,
    'duration': duration.inSeconds,
    'channelId': channelId,
    'channelName': channelName,
    'viewCount': viewCount,
    'publishedAt': publishedAt.toIso8601String(),
    'tags': tags,
    'artistId': artistId,
    'artistName': artistName,
    if (albumId != null) 'albumId': albumId,
    if (albumName != null) 'albumName': albumName,
  };
}