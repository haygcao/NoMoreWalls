import 'package:spotube/core/base/services/base_service.dart';
import 'package:spotube/core/base/models/track_model.dart';

/// 音轨服务接口
abstract class TrackService extends BaseService {
  /// 获取音轨详情
  Future<TrackModel?> getTrack(String trackId);
  
  /// 获取多个音轨详情
  Future<List<TrackModel>> getTracks(List<String> trackIds);
  
  /// 获取推荐音轨
  Future<List<TrackModel>> getRecommendedTracks({int limit = 20, int offset = 0});
  
  /// 获取用户最近播放的音轨
  Future<List<TrackModel>> getRecentlyPlayedTracks({int limit = 20});
}