part of '../youtube_music.dart';

final youtubeMusicLikedTracksProvider = StateNotifierProvider<YoutubeMusicLikedTracksNotifier, AsyncValue<List<YoutubeMusicTrack>>>((ref) {
  final service = ref.watch(youtubeMusicProvider);
  return YoutubeMusicLikedTracksNotifier(service);
});

class YoutubeMusicLikedTracksNotifier extends StateNotifier<AsyncValue<List<YoutubeMusicTrack>>> {
  final YoutubeMusicService _service;

  YoutubeMusicLikedTracksNotifier(this._service) : super(const AsyncValue.loading()) {
    getLikedTracks();
  }

  Future<void> getLikedTracks() async {
    try {
      state = const AsyncValue.loading();
      final tracks = await _service.getLikedTracks();
      state = AsyncValue.data(tracks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleLike(String trackId) async {
    try {
      // 获取当前状态
      final currentTracks = state.value ?? [];
      final isLiked = currentTracks.any((track) => track.id == trackId);

      if (isLiked) {
        // 如果已经喜欢，则取消喜欢
        await _service.unlikeTrack(trackId);
        // 更新状态，移除该音轨
        state = AsyncValue.data(currentTracks.where((track) => track.id != trackId).toList());
      } else {
        // 如果未喜欢，则添加到喜欢
        await _service.likeTrack(trackId);
        // 刷新喜欢列表
        await getLikedTracks();
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}