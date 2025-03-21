class YoutubeMusicCredentials {
  final String accessToken;
  final DateTime expiration;
  final bool isAnonymous;
  final Map<String, String> cookies;

  const YoutubeMusicCredentials({
    required this.accessToken,
    required this.expiration,
    required this.isAnonymous,
    required this.cookies,
  });

  YoutubeMusicCredentials.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'],
        expiration = DateTime.fromMillisecondsSinceEpoch(
          json['accessTokenExpirationTimestampMs'],
        ),
        isAnonymous = json['isAnonymous'],
        cookies = Map<String, String>.from(json['cookies']);

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'accessTokenExpirationTimestampMs': expiration.millisecondsSinceEpoch,
    'isAnonymous': isAnonymous,
    'cookies': cookies,
  };
}