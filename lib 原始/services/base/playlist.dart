
import 'package:spotube/services/base/collection.dart';

class Playlist implements PlaylistCollection {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String uri;
  @override
  final String type = 'playlist';
  @override
  final String? owner;
  @override
  final bool isPublic;
  @override
  final bool collaborative;
  @override
  final int totalTracks;

  // 平台特定的额外信息
  final Map<String, dynamic>? platformMetadata;

  const Playlist({
    required this.id,
    required this.name,
    required this.uri,
    this.description,
    this.imageUrl,
    this.owner,
    this.isPublic = true,
    this.collaborative = false,
    this.totalTracks = 0,
    this.platformMetadata,
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'uri': uri,
    if (description != null) 'description': description,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (owner != null) 'owner': owner,
    'isPublic': isPublic,
    'collaborative': collaborative,
    'totalTracks': totalTracks,
    if (platformMetadata != null) 'platformMetadata': platformMetadata,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      owner: json['owner'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      collaborative: json['collaborative'] as bool? ?? false,
      totalTracks: json['totalTracks'] as int? ?? 0,
      platformMetadata: json['platformMetadata'] as Map<String, dynamic>?,
    );
  }
}
