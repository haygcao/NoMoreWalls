part of '../youtube_music.dart';

// 艺人详情
final youtubeMusicArtistProvider = FutureProvider.family<YoutubeMusicChannel, String>((ref, artistId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getArtist(artistId);
});

// 艺人热门歌曲
final youtubeMusicArtistTopTracksProvider = FutureProvider.family<List<YoutubeMusicTrack>, String>((ref, artistId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getArtistTopTracks(artistId);
});

// 艺人专辑
final youtubeMusicArtistAlbumsProvider = FutureProvider.family<List<YoutubeMusicAlbum>, String>((ref, artistId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getArtistAlbums(artistId);
});

// 关注的艺人
final youtubeMusicArtistFollowingProvider = FutureProvider<List<YoutubeMusicChannel>>((ref) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.getFollowedArtists();
});

// 是否关注艺人
final youtubeMusicArtistIsFollowingProvider = FutureProvider.family<bool, String>((ref, artistId) async {
  final service = ref.watch(youtubeMusicProvider);
  return await service.isFollowingArtist(artistId);
});