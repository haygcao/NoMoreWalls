import 'package:spotube/core/base/interfaces/media/track_interface.dart';

/// 播放队列接口
abstract class QueueInterface {
  /// 获取当前队列
  List<TrackInterface> get queue;
  
  /// 添加曲目到队列
  void addToQueue(TrackInterface track);
  
  /// 添加多个曲目到队列
  void addAllToQueue(List<TrackInterface> tracks);
  
  /// 从队列中移除曲目
  void removeFromQueue(TrackInterface track);
  
  /// 清空队列
  void clearQueue();
  
  /// 获取下一曲
  TrackInterface? getNextTrack();
  
  /// 获取上一曲
  TrackInterface? getPreviousTrack();
  
  /// 设置当前播放索引
  void setCurrentIndex(int index);
  
  /// 获取当前播放索引
  int get currentIndex;
}