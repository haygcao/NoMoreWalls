import 'package:spotube/core/base/models/media_model.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';

/// 专辑模型基类
abstract class AlbumModel extends MediaModel implements AlbumInterface {
  @override
  final String? description;
  
  @override
  final DateTime? releaseDate;
  
  @override
  final List<String>? artistIds;
  
  @override
  final List<String>? artistNames;
  
  @override
  final String? albumType;
  
  @override
  final int totalTracks;
  
  AlbumModel({
    required String id,
    required String name,
    String? imageUrl,
    this.description,
    this.releaseDate,
    this.artistIds,
    this.artistNames,
    this.albumType,
    required this.totalTracks,
  }) : super(
    id: id,
    name: name,
    imageUrl: imageUrl,
    type: 'album',
  );
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'description': description,
      'releaseDate': releaseDate?.toIso8601String(),
      'artistIds': artistIds,
      'artistNames': artistNames,
      'albumType': albumType,
      'totalTracks': totalTracks,
    };
  }
}