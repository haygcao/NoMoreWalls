import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 特定的导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/dialogs/playlist_add_track_dialog.dart';
import 'package:spotube/components/dialogs/prompt_dialog.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
// 导入基础接口
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/track_factory.dart';
// 导入 Spotify 相关类型
import 'package:spotify/spotify.dart' show Track, SearchType, Playlist;

class TrackOptionsActions {
  // 修改方法签名，使用 SourceableTrack 替代 Track
  static void actionShare(BuildContext context, SourceableTrack track) {
    // 根据轨道类型生成不同的分享链接
    final bool isYoutubeTrack = track.id.startsWith('youtube:') || track.id.contains('youtube');
    final String data = isYoutubeTrack
        ? "https://music.youtube.com/watch?v=${track.id.replaceAll('youtube:', '')}"
        : "https://open.spotify.com/track/${track.id}";
        
    Clipboard.setData(ClipboardData(text: data)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: 300,
          behavior: SnackBarBehavior.floating,
          content: Text(
            context.l10n.copied_to_clipboard(data),
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  // 修改方法签名，使用 SourceableTrack 替代 Track
  static void actionAddToPlaylist(
    BuildContext context,
    SourceableTrack track,
    String? playlistId,
  ) {
    // 检查是否为 YouTube 轨道
    final bool isYoutubeTrack = track.id.startsWith('youtube:') || track.id.contains('youtube');
    
    if (isYoutubeTrack) {
      // 直接使用 Consumer 获取 YouTubeMusic 相关提供者
      showDialog(
        context: context,
        builder: (context) => Consumer(
          builder: (context, ref, _) {
            // 使用现有的 youtubeMusicUserPlaylistsProvider
            return FutureBuilder(
              future: ref.read(youtubeMusicUserPlaylistsProvider.future),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    content: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasError || !snapshot.hasData) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: const Text("Failed to load playlists"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.close),
                      ),
                    ],
                  );
                }
                
                final playlists = snapshot.data!;
                
                return AlertDialog(
                  title: Text(context.l10n.add_to_playlist),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return ListTile(
                          title: Text(playlist.title),
                          subtitle: Text('${playlist.trackCount} tracks'),
                          leading: playlist.thumbnailUrl.isNotEmpty
                              ? Image.network(
                                  playlist.thumbnailUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.playlist_play),
                          onTap: () async {
                            // 使用现有的 youtubeMusicPlaylistActionsProvider
                            final playlistActions = ref.read(youtubeMusicPlaylistActionsProvider);
                            await playlistActions.addTrackToPlaylist(
                              playlist.id,
                              track.id,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Added ${track.title} to ${playlist.title}",
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.cancel),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
    } else {
      // 对于 Spotify 轨道，使用现有的对话框
      showDialog(
        context: context,
        builder: (context) => PlaylistAddTrackDialog(
          tracks: [track],
          openFromPlaylist: playlistId,
        ),
      );
    }
  }

  // 修改方法签名，使用 SourceableTrack 替代 Track
  static Future<void> actionStartRadio(
    BuildContext context,
    WidgetRef ref,
    SourceableTrack track,
  ) async {
    final playback = ref.read(audioPlayerProvider.notifier);
    final playlist = ref.read(audioPlayerProvider);
    final prefs = ref.read(userPreferencesProvider);
    
    // 检查是否为 YouTube 轨道
    final bool isYoutubeTrack = track.id.startsWith('youtube:') || track.id.contains('youtube');
    
    // 使用传入的 track，不需要再创建
    final sourceableTrack = track;
    
    // 使用 AudioSource 枚举
    final isYouTubeMusic = prefs.audioSource == AudioSource.youtube || isYoutubeTrack;
    
    List<SourceableTrack> radioTracks = [];
    
    if (isYouTubeMusic) {
      final youtubeMusic = ref.read(youtubeMusicProvider);
      final query = "${track.title} ${track.artistName}";
      
      // 使用 YouTube Music 的 search API 获取相关歌曲
      final searchResponse = await youtubeMusic.search(query);
      
      // 确保 YouTube Music 的搜索结果是 SourceableTrack 类型
      radioTracks = searchResponse.tracks.map((t) => 
        TrackFactory.createFromJson({
          ...t.toJson(),
          'track_type': 'youtube_music'
        })
      ).toList();
    } else {
      final spotify = ref.read(spotifyProvider);
      final query = "${track.title} Radio";
      final pages = await spotify.search.get(query, types: [SearchType.playlist]).first();
      
      final radios = pages
          .expand((e) => e.items?.cast<Playlist>().toList() ?? [])
          .toList();

      final artists = [track.artistName];
      final radio = radios.firstWhere(
        (e) {
          final validPlaylists = artists.where((a) => e.description!.contains(a));
          return e.name == "${track.title} Radio" &&
              (validPlaylists.length >= 2 ||
                  validPlaylists.length == artists.length) &&
              e.owner?.displayName == "Spotify";
        },
        orElse: () => radios.first,
      );
      
      // 获取原始 Spotify 曲目，然后转换为 SourceableTrack
      final spotifyTracks = await spotify.playlists.getTracksByPlaylistId(radio.id!).all();
      radioTracks = spotifyTracks.map((t) => 
        TrackFactory.createFromJson({
          ...t.toJson(),
          'track_type': 'spotify'
        })
      ).toList();
    }
  
    bool replaceQueue = false;
    if (context.mounted && playlist.tracks.isNotEmpty) {
      replaceQueue = await showPromptDialog(
        context: context,
        title: context.l10n.how_to_start_radio,
        message: context.l10n.replace_queue_question,
        okText: context.l10n.replace,
        cancelText: context.l10n.add_to_queue,
      );
    }
  
    if (replaceQueue || playlist.tracks.isEmpty) {
      await playback.stop();
      await playback.load([sourceableTrack], autoPlay: true);
      return;
    } else {
      await playback.addTrack(sourceableTrack);
    }
  
    await playback.addTracks(
      radioTracks
        ..removeWhere((e) {
          final isDuplicate = playlist.tracks.any((t) => t.id == e.id);
          return e.id == track.id || isDuplicate;
        }),
    );
  }
}