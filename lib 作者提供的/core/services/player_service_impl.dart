import 'package:spotube/core/base/services/player_service.dart';
import 'package:spotube/core/base/interfaces/media/track_interface.dart';
import 'package:spotube/core/base/interfaces/player/playback_interface.dart';
import 'package:spotube/core/platform/platform_registry.dart';

/// 核心播放器服务实现
class PlayerServiceImpl {
  // 单例实例
  static final PlayerServiceImpl _instance = PlayerServiceImpl._internal();
  
  // 获取单例实例
  static PlayerServiceImpl get instance => _instance;
  
  // 私有构造函数
  PlayerServiceImpl._internal();
  
  /// 获取所有平台的播放器服务
  Map<String, PlayerService> getAllPlayerServices() {
    return PlatformRegistry.instance.getAllServicesOfType<PlayerService>();
  }
  
  /// 获取特定平台的播放器服务
  PlayerService? getPlayerServiceForPlatform(String platformId) {
    return PlatformRegistry.instance.getServiceForPlatform<PlayerService>(platformId);
  }
  
  /// 获取当前活跃平台的播放器服务
  PlayerService? getActivePlayerService() {
    return PlatformRegistry.instance.getActiveService<PlayerService>();
  }
  
  /// 播放指定曲目
  Future<void> play(TrackInterface track) async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.play(track);
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 暂停播放
  Future<void> pause() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.pause();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 恢复播放
  Future<void> resume() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.resume();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 停止播放
  Future<void> stop() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.stop();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 跳到下一曲
  Future<void> next() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.next();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 跳到上一曲
  Future<void> previous() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.previous();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 设置音量
  Future<void> setVolume(double volume) async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.setVolume(volume);
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 设置播放速度
  Future<void> setPlaybackRate(double rate) async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.setPlaybackRate(rate);
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 设置重复模式
  Future<void> setRepeatMode(RepeatMode mode) async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.setRepeatMode(mode);
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 设置随机播放
  Future<void> setShuffle(bool enabled) async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.setShuffle(enabled);
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      await playerService.seekTo(position);
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 获取当前播放状态
  Future<Map<String, dynamic>> getPlaybackState() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      return await playerService.getPlaybackState();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 获取当前播放位置
  Future<Duration> getCurrentPosition() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      return await playerService.getCurrentPosition();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
  
  /// 获取当前曲目总时长
  Future<Duration> getDuration() async {
    final playerService = getActivePlayerService();
    
    if (playerService != null) {
      return await playerService.getDuration();
    } else {
      throw Exception('未找到活跃平台的播放器服务');
    }
  }
}