import 'package:spotube/core/base/models/media_model.dart';
import 'package:spotube/core/base/interfaces/media/playlist_interface.dart';

/// 播放列表模型基类
abstract class PlaylistModel extends MediaModel implements PlaylistInterface {
  @override
  final String? description;
  
  @override
  final String? owner;
  
  @override
  final bool isPublic;
  
  @override
  final bool collaborative;
  
  @override
  final int totalTracks;
  
  PlaylistModel({
    required String id,
    required String name,
    String? imageUrl,
    this.description,
    this.owner,
    required this.isPublic,
    required this.collaborative,
    required this.totalTracks,
  }) : super(
    id: id,
    name: name,
    imageUrl: imageUrl,
    type: 'playlist',
  );
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'description': description,
      'owner': owner,
      'isPublic': isPublic,
      'collaborative': collaborative,
      'totalTracks': totalTracks,
    };
  }
}