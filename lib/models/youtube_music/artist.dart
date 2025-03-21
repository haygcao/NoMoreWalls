class YoutubeMusicArtist {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? browseId;
  final String? description;

  const YoutubeMusicArtist({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.browseId,
    this.description,
  });

  factory YoutubeMusicArtist.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicArtist(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      browseId: json['browseId'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'browseId': browseId,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'YoutubeMusicArtist(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YoutubeMusicArtist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}