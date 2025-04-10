part of '../youtube_music.dart';

// YouTube Music 首页推荐内容 provider
final youtubeMusicHomeProvider = FutureProvider<List<YoutubeMusicSection>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getHomeContent();
});

// YouTube Music 首页分区内容 provider
final youtubeMusicSectionProvider = FutureProvider.family<YoutubeMusicSection, String>((ref, sectionId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getSectionContent(sectionId);
});