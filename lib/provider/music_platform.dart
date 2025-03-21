// 当前音乐平台提供者
import 'package:hooks_riverpod/hooks_riverpod.dart';


final currentMusicPlatformProvider = StateProvider<MusicPlatform>((ref) {
  // 默认使用 Spotify
  return MusicPlatform.spotify;
});

enum MusicPlatform {
  spotify,
  youtubeMusic,
  mixed,  // 添加混合模式
  // 未来可以添加其他平台
}