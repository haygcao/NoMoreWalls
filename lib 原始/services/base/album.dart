import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:spotube/services/base/collection.dart';  // 添加这个导入

// 修改实现接口
class Album implements AlbumBase, AlbumCollection {  // 实现 AlbumCollection
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
  final String type = CollectionType.album.name;  // 使用枚举
  @override
  final DateTime? releaseDate;
  @override
  final List<String>? artists;
  @override
  final String? albumType;
  @override
  final List<SourceableTrack>? tracks;
  
  // 平台特定的额外信息
  final Map<String, dynamic>? platformMetadata;

  Album({
    required this.id,
    required this.name,
    required this.uri,
    this.description,
    this.imageUrl,
    this.releaseDate,
    this.artists,
    this.albumType,
    this.tracks,
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
    if (releaseDate != null) 'releaseDate': releaseDate!.toIso8601String(),
    if (artists != null) 'artists': artists,
    if (albumType != null) 'albumType': albumType,
    if (tracks != null) 'tracks': tracks!.map((t) => t.toJson()).toList(),
    if (platformMetadata != null) 'platformMetadata': platformMetadata,
  };

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      releaseDate: json['releaseDate'] != null 
          ? DateTime.parse(json['releaseDate']) 
          : null,
      artists: json['artists'] != null 
          ? List<String>.from(json['artists']) 
          : null,
      albumType: json['albumType'] as String?,
      tracks: json['tracks'] != null 
          ? (json['tracks'] as List)
              .map((t) => SourcedTrack.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
      platformMetadata: json['platformMetadata'] as Map<String, dynamic>?,
    );
  }
}