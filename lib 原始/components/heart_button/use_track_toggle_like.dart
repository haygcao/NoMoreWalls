import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/scrobbler/scrobbler.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotify/spotify.dart' as spotify;

typedef UseTrackToggleLike = ({
  bool isLiked,
  Future<void> Function(SourceableTrack track) toggleTrackLike,
});

UseTrackToggleLike useTrackToggleLike(SourceableTrack track, WidgetRef ref) {
  // 判断音轨来源
  final isYoutubeTrack = track.id.startsWith('youtube:') || track.id.contains('youtube');
  
  // Spotify 收藏音轨
  final spotifySavedTracks = ref.watch(likedTracksProvider);
  final spotifySavedTracksNotifier = ref.watch(likedTracksProvider.notifier);
  
  // YouTube Music 收藏音轨
  final youtubeMusicState = ref.watch(youtubeMusicStateProvider);
  // 使用 StateNotifierProvider 而不是 FutureProvider
  final youtubeLikedTracksNotifier = ref.watch(youtubeMusicLikedTracksProvider.notifier);

  final isLiked = useMemoized(() {
    if (isYoutubeTrack) {
      // YouTube Music 收藏逻辑
      final likedTracks = youtubeMusicState.library?.likedTracks ?? [];
      return likedTracks.any((element) => element.id == track.id);
    } else {
      // Spotify 收藏逻辑
      return spotifySavedTracks.asData?.value.any((element) => element.id == track.id) ?? false;
    }
  }, [
    spotifySavedTracks.asData?.value, 
    youtubeMusicState.library?.likedTracks, 
    track.id
  ]);

  final scrobblerNotifier = ref.read(scrobblerProvider.notifier);

  return (
    isLiked: isLiked,
    toggleTrackLike: (track) async {
      if (isYoutubeTrack) {
        // YouTube Music 收藏/取消收藏逻辑
        await youtubeLikedTracksNotifier.toggleLike(track.id);
      } else {
        // Spotify 收藏逻辑 - 需要将 SourceableTrack 转换为 spotify.Track
        final spotifyTrack = track as spotify.Track;
        await spotifySavedTracksNotifier.toggleFavorite(spotifyTrack);
      }

      if (!isLiked) {
        await scrobblerNotifier.love(track);
      } else {
        await scrobblerNotifier.unlove(track);
      }
    },
  );
}
