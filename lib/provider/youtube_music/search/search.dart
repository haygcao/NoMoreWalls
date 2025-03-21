part of '../youtube_music.dart';

final youtubeMusicSearchProvider = FutureProvider.family<YoutubeMusicSearchResults, String>((ref, query) async {
  final service = ref.watch(youtubeMusicProvider);  // 修改为正确的 provider
  return await service.search(query);
});

final youtubeMusicSearchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  final service = ref.watch(youtubeMusicProvider);  // 修改为正确的 provider
  return await service.getSearchSuggestions(query);
});