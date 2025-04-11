import 'package:spotube/core/base/providers/media_provider.dart';
import 'package:spotube/core/base/interfaces/media/album_interface.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 专辑提供者接口
abstract class AlbumProvider extends MediaProvider<AlbumInterface> {
  /// 获取专辑曲目
  Future<List<TrackInterface>> getTracks({int limit = 20, int offset = 0});
  
  /// 专辑曲目
  List<TrackInterface> get tracks;
  
  /// 专辑曲目是否已加载
  bool get tracksLoaded;
}