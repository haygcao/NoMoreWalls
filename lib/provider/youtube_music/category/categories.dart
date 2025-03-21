part of '../youtube_music.dart';

final youtubeMusicCategoriesProvider = FutureProvider<List<YoutubeMusicCategory>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getCategories();
});

final youtubeMusicCategoryPlaylistsProvider = FutureProvider.family<List<YoutubeMusicPlaylist>, String>((ref, categoryId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getCategoryPlaylists(categoryId);
});