import 'package:flutter/foundation.dart';

/// Base class for all models in the application
///
/// Provides common functionality for models
@immutable
abstract class BaseModel {
  /// Unique identifier for the model
  final String id;

  /// Platform source of this model (e.g., "spotify", "youtube_music")
  final String platform;

  /// Create a new base model
  const BaseModel({
    required this.id,
    required this.platform,
  });

  /// Convert the model to a JSON representation
  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform,
      };

  /// Create a copy of this model with updated properties
  BaseModel copyWith({
    String? id,
    String? platform,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          platform == other.platform;

  @override
  int get hashCode => id.hashCode ^ platform.hashCode;
}
