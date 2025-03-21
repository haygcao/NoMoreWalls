part of '../youtube_music.dart';

final youtubeMusicUserLibraryProvider = FutureProvider<YoutubeMusicLibrary>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getUserLibrary();
});