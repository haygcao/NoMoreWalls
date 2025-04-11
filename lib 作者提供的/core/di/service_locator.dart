import 'package:get_it/get_it.dart';
import 'package:spotube/core/di/service_registry.dart';
import 'package:spotube/platforms/spotify/services/spotify_auth_service.dart';
import 'package:spotube/platforms/spotify/services/spotify_track_service.dart';
import 'package:spotube/platforms/spotify/services/spotify_album_service.dart';
import 'package:spotube/platforms/spotify/services/spotify_artist_service.dart';
import 'package:spotube/platforms/spotify/services/spotify_playlist_service.dart';
import 'package:spotube/platforms/spotify/services/spotify_search_service.dart';
import 'package:spotube/platforms/spotify/services/spotify_player_service.dart';
import 'package:spotube/platforms/youtube/services/youtube_auth_service.dart';
import 'package:spotube/platforms/youtube/services/youtube_track_service.dart';
import 'package:spotube/platforms/youtube/services/youtube_search_service.dart';
import 'package:spotube/platforms/youtube/services/youtube_player_service.dart';

/// 服务定位器，负责设置依赖注入
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  /// 获取GetIt实例
  static GetIt get getIt => _getIt;
  
  /// 设置依赖注入
  static Future<void> setupDependencies() async {
    // 注册服务注册表
    _getIt.registerSingleton<ServiceRegistry>(ServiceRegistry.instance);
    
    // 注册平台服务
    await _registerPlatformServices();
  }
  
  /// 注册平台服务
  static Future<void> _registerPlatformServices() async {
    // 注册Spotify服务
    _registerSpotifyServices();
    
    // 注册YouTube服务
    _registerYouTubeServices();
    
    // 可以在这里添加更多平台的服务注册
  }
  
  /// 注册Spotify服务
  static void _registerSpotifyServices() {
    final registry = _getIt.get<ServiceRegistry>();
    
    // 创建并注册Spotify服务
    registry.register(SpotifyAuthService());
    registry.register(SpotifyTrackService());
    registry.register(SpotifyAlbumService());
    registry.register(SpotifyArtistService());
    registry.register(SpotifyPlaylistService());
    registry.register(SpotifySearchService());
    registry.register(SpotifyPlayerService());
  }
  
  /// 注册YouTube服务
  static void _registerYouTubeServices() {
    final registry = _getIt.get<ServiceRegistry>();
    
    // 创建并注册YouTube服务
    registry.register(YouTubeAuthService());
    registry.register(YouTubeTrackService());
    registry.register(YouTubeSearchService());
    registry.register(YouTubePlayerService());
  }
  
  /// 获取服务实例
  static T get<T extends Object>({String? instanceName}) {
    return _getIt.get<T>(instanceName: instanceName);
  }
  
  /// 异步获取服务实例
  static Future<T> getAsync<T extends Object>({String? instanceName}) {
    return _getIt.getAsync<T>(instanceName: instanceName);
  }
  
  /// 重置所有注册的服务
  static void reset() {
    _getIt.reset();
  }
}