class YoutubeMusicCategory {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;

  const YoutubeMusicCategory({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
  });

  factory YoutubeMusicCategory.fromJson(Map<String, dynamic> json) {
    return YoutubeMusicCategory(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
  };
}