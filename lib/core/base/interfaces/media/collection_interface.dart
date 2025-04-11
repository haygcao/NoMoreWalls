import 'package:flutter/foundation.dart';
import 'media_interface.dart';

/// Interface for collection media type
///
/// Defines the properties and methods specific to media collections
/// Collections can be used to group related media items together
@immutable
abstract class CollectionInterface extends MediaInterface {
  /// Description of the collection
  String? get description;

  /// Type of the collection (e.g., "featured", "new-releases", "genres")
  String get collectionType;

  /// Total number of items in the collection
  int get totalItems;

  /// Platform-specific metadata
  Map<String, dynamic> get platformMetadata;
}
