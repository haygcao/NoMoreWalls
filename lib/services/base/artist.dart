import 'package:spotube/services/base/base_models.dart';

class Artist implements ArtistBase {
  @override
  final String id;
  @override
  final String name;
  final String uri;
  @override
  final String? imageUrl;
  @override
  final String? description;
  final Map<String, dynamic> platformMetadata;

  const Artist({
    required this.id,
    required this.name,
    required this.uri,
    this.imageUrl,
    this.description,
    this.platformMetadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          uri == other.uri;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ uri.hashCode;

  @override
  String toString() {
    return 'Artist(id: $id, name: $name, uri: $uri)';
  }

  Artist copyWith({
    String? id,
    String? name,
    String? uri,
    String? imageUrl,
    String? description,
    Map<String, dynamic>? platformMetadata,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      uri: uri ?? this.uri,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uri': uri,
      'imageUrl': imageUrl,
      'description': description,
      'platformMetadata': platformMetadata,
    };
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      uri: json['uri'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      platformMetadata: json['platformMetadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}