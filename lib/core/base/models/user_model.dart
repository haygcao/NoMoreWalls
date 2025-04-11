import 'package:flutter/foundation.dart';
import '../interfaces/auth/user_interface.dart';

/// Model class for users
///
/// Implements the UserInterface
@immutable
class UserModel implements UserInterface {
  /// Unique identifier for the user
  final String id;

  /// Display name of the user
  final String displayName;

  /// Email address of the user (if available)
  final String? email;

  /// URL to the user's profile image
  final String? imageUrl;

  /// Country code of the user
  final String? country;

  /// Number of followers the user has
  final int? followersCount;

  /// Type of subscription the user has
  final String? subscriptionType;

  /// Platform this user belongs to (e.g., "spotify", "youtube_music")
  final String platform;

  /// Platform-specific metadata
  final Map<String, dynamic> platformMetadata;

  /// Create a new user model
  const UserModel({
    required this.id,
    required this.displayName,
    required this.platform,
    this.email,
    this.imageUrl,
    this.country,
    this.followersCount,
    this.subscriptionType,
    this.platformMetadata = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'imageUrl': imageUrl,
        'country': country,
        'followersCount': followersCount,
        'subscriptionType': subscriptionType,
        'platform': platform,
        'platformMetadata': platformMetadata,
      };

  /// Create a copy of this model with updated properties
  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? imageUrl,
    String? country,
    int? followersCount,
    String? subscriptionType,
    String? platform,
    Map<String, dynamic>? platformMetadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      country: country ?? this.country,
      followersCount: followersCount ?? this.followersCount,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      platform: platform ?? this.platform,
      platformMetadata: platformMetadata ?? this.platformMetadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          email == other.email &&
          imageUrl == other.imageUrl &&
          country == other.country &&
          followersCount == other.followersCount &&
          subscriptionType == other.subscriptionType &&
          platform == other.platform;

  @override
  int get hashCode =>
      id.hashCode ^
      displayName.hashCode ^
      email.hashCode ^
      imageUrl.hashCode ^
      country.hashCode ^
      followersCount.hashCode ^
      subscriptionType.hashCode ^
      platform.hashCode;
}
