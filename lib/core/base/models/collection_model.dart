import 'package:flutter/foundation.dart';
import '../interfaces/media/collection_interface.dart';
import 'media_model.dart';

/// Model class for collections
///
/// Implements the CollectionInterface and extends MediaModel
@immutable
class CollectionModel extends MediaModel implements CollectionInterface {
  /// Description of the collection
  final String? description;

  /// Type of the collection (e.g., "featured", "new-releases", "genres")
  final String collectionType;

  /// Total number of items in the collection
  final int totalItems;

  /// Platform-specific metadata
  final Map<String, dynamic> platformMetadata;

  /// Create a new collection model
  const CollectionModel({
    required super.id,
    required super.platform,
    required super.name,
    super.imageUrl,
    this.description,
    required this.collectionType,
    required this.totalItems,
    this.platformMetadata = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'description': description,
        'collectionType': collectionType,
        'totalItems': totalItems,
        'platformMetadata': platformMetadata,
      };

  @override
  CollectionModel copyWith({
    String? id,
    String? platform,
    String? name,
    String? imageUrl,
    String? description,
    String? collectionType,
    int? totalItems,
    Map<String, dynamic>? platformMetadata,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      collectionType: collectionType ?? this.collectionType,
      totalItems: totalItems ?? this.totalItems,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CollectionModel &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          collectionType == other.collectionType &&
          totalItems == other.totalItems;

  @override
  int get hashCode =>
      super.hashCode ^
      description.hashCode ^
      collectionType.hashCode ^
      totalItems.hashCode;
}
