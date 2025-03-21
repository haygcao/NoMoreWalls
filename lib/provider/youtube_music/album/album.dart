part of '../youtube_music.dart';

// 专辑详情
final youtubeMusicAlbumProvider = FutureProvider.family<YoutubeMusicAlbum, String>((ref, albumId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getAlbum(albumId);
});

// 专辑曲目
final youtubeMusicAlbumTracksProvider = FutureProvider.family<List<YoutubeMusicTrack>, String>((ref, albumId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getAlbumTracks(albumId);
});

// 新发行
final youtubeMusicNewReleasesProvider = FutureProvider<List<YoutubeMusicAlbum>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getNewReleases();
});