import 'package:flutter/foundation.dart';

/// Interface for user information
///
/// Defines the properties that represent a user across platforms
@immutable
abstract class UserInterface {
  /// Unique identifier for the user
  String get id;

  /// Display name of the user
  String get displayName;

  /// Email address of the user (if available)
  String? get email;

  /// URL to the user's profile image
  String? get imageUrl;

  /// Country code of the user
  String? get country;

  /// Number of followers the user has
  int? get followersCount;

  /// Type of subscription the user has
  String? get subscriptionType;

  /// Platform this user belongs to (e.g., "spotify", "youtube_music")
  String get platform;

  /// Platform-specific metadata
  Map<String, dynamic> get platformMetadata;

  /// Convert the user to a JSON representation
  Map<String, dynamic> toJson();
}
