import 'package:spotube/core/base/interfaces/media/media_interface.dart';

/// Base implementation of MediaInterface that provides common functionality
class MediaModel implements MediaInterface {
  @override
  final String id;

  @override
  final String name;

  @override
  final String? imageUrl;

  @override
  final int? duration;

  @override
  final Map<String, dynamic> metadata;

  const MediaModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.duration,
    this.metadata = const {},
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'duration': duration,
      'metadata': metadata,
    };
  }

  @override
  MediaModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? duration,
    Map<String, dynamic>? metadata,
  }) {
    return MediaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imageUrl == other.imageUrl &&
          duration == other.duration;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ imageUrl.hashCode ^ duration.hashCode;
}
