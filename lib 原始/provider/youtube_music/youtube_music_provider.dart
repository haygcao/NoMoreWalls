
// 创建全局 service provider
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/models/youtube_music/section.dart';

import 'package:spotube/provider/youtube_music/auth_provider.dart';
import 'package:spotube/services/youtube_music/youtube_music_service.dart';

final youtubeMusicProvider = Provider<YoutubeMusicService>((ref) {
  final auth = ref.watch(youtubeMusicAuthProvider);
  // 如果有认证信息，使用认证服务；否则使用匿名服务
  return auth.value != null 
      ? YoutubeMusicService(credentials: auth.value)
      : YoutubeMusicService.anonymous();
});

// 添加首页内容 provider
final youtubeMusicHomeSectionsProvider = FutureProvider<List<YoutubeMusicSection>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getHomeContent();
});

