import 'package:json_annotation/json_annotation.dart';



@JsonSerializable()
class YoutubeMusicUser {
  final String channelId;
  final String name;
  final String? thumbnailUrl;
  final String? email;

  const YoutubeMusicUser({
    required this.channelId,
    required this.name,
    this.thumbnailUrl,
    this.email,
  });

  factory YoutubeMusicUser.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicUser(
      channelId: json['channelId'] as String,
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      email: json['email'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'channelId': channelId,
    'name': name,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (email != null) 'email': email,
  };
}

class YoutubeMusicUserActivity {
  final YoutubeMusicUser user;
  final String? currentTrackId;
  final DateTime? lastActive;

  const YoutubeMusicUserActivity({
    required this.user,
    this.currentTrackId,
    this.lastActive,
  });

  factory YoutubeMusicUserActivity.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicUserActivity(
      user: YoutubeMusicUser.fromJson(json['user'] as Map<String, dynamic>),
      currentTrackId: json['currentTrackId'] as String?,
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    if (currentTrackId != null) 'currentTrackId': currentTrackId,
    if (lastActive != null) 'lastActive': lastActive!.toIso8601String(),
  };
}