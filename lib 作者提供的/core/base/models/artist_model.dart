import 'package:spotube/core/base/models/media_model.dart';
import 'package:spotube/core/base/interfaces/media/artist_interface.dart';

/// 艺术家模型基类
abstract class ArtistModel extends MediaModel implements ArtistInterface {
  @override
  final String? description;
  
  @override
  final List<String>? genres;
  
  @override
  final int? followersCount;
  
  ArtistModel({
    required String id,
    required String name,
    String? imageUrl,
    this.description,
    this.genres,
    this.followersCount,
  }) : super(
    id: id,
    name: name,
    imageUrl: imageUrl,
    type: 'artist',
  );
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'description': description,
      'genres': genres,
      'followersCount': followersCount,
    };
  }
}