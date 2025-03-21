class YoutubeMusicChannel {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final int subscriberCount;
  final bool isVerified;

  const YoutubeMusicChannel({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.subscriberCount = 0,
    this.isVerified = false,
  });

  factory YoutubeMusicChannel.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicChannel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      subscriberCount: json['subscriberCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    'subscriberCount': subscriberCount,
    'isVerified': isVerified,
  };
}