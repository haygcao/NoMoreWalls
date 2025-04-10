import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart' as spotify;
import 'package:spotube/provider/youtube_music/youtube_music.dart' as youtube_music;

// 检查专辑是否已收藏的通用提供者
final albumsIsSavedProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, albumId) async {
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    
    switch (currentPlatform) {
      case MusicPlatform.spotify:
        // 使用 Spotify 的 albumsIsSavedProvider
        return ref.watch(spotify.albumsIsSavedProvider(albumId)).value ?? false;
      
      case MusicPlatform.youtubeMusic:
        // 使用 YouTube Music 的专辑收藏检查
        final library = await ref.watch(youtube_music.youtubeMusicUserLibraryProvider.future);
        return library.albums.any((album) => album.id == albumId);
      
      case MusicPlatform.mixed:
        // 混合模式下，先检查 Spotify，再检查 YouTube Music
        final isSpotifySaved = await ref.watch(spotify.albumsIsSavedProvider(albumId).future).catchError((_) => false);
        if (isSpotifySaved) return true;
        
        try {
          final library = await ref.watch(youtube_music.youtubeMusicUserLibraryProvider.future);
          return library.albums.any((album) => album.id == albumId);
        } catch (_) {
          return false;
        }
      
      default:
        return false;
    }
  },
);