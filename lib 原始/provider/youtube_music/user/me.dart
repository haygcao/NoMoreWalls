part of '../youtube_music.dart';

final youtubeMusicUserProvider = FutureProvider<YoutubeMusicUser?>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getCurrentUser();
});

