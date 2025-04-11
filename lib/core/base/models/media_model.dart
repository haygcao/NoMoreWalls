import 'package:flutter/foundation.dart';
import '../interfaces/media/media_interface.dart';
import 'base_model.dart';

/// Base class for all media models in the application
///
/// Implements the MediaInterface and extends BaseModel
@immutable
abstract class MediaModel extends BaseModel implements MediaInterface {
  /// Name or title of the media
  final String name;

  /// URL to the media's image/thumbnail
  final String? imageUrl;

  /// Create a new media model
  const MediaModel({
    required super.id,
    required super.platform,
    required this.name,
    this.imageUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
        'imageUrl': imageUrl,
      };

  @override
  MediaModel copyWith({
    String? id,
    String? platform,
    String? name,
    String? imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is MediaModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => super.hashCode ^ name.hashCode ^ imageUrl.hashCode;
}
