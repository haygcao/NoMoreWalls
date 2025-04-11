import 'package:spotube/core/base/models/media_model.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 音轨模型基类
abstract class TrackModel extends MediaModel implements TrackInterface {
  @override
  final String? artistName;
  
  @override
  final String? albumName;
  
  @override
  final int? durationMs;
  
  @override
  final bool isPlayable;
  
  TrackModel({
    required String id,
    required String name,
    String? imageUrl,
    this.artistName,
    this.albumName,
    this.durationMs,
    required this.isPlayable,
  }) : super(
    id: id,
    name: name,
    imageUrl: imageUrl,
    type: 'track',
  );
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'artistName': artistName,
      'albumName': albumName,
      'durationMs': durationMs,
      'isPlayable': isPlayable,
    };
  }
  
  @override
  Future<String?> getStreamUrl();
}