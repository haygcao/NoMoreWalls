import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/services/logger/logger.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/youtube_music/youtube_music_service.dart';
import 'package:spotube/services/track_factory.dart';

void useEndlessPlayback(WidgetRef ref) {
  final auth = ref.watch(authenticationProvider);
  final playback = ref.watch(audioPlayerProvider.notifier);
  final playlist = ref.watch(audioPlayerProvider.select((s) => s.playlist));
  final preferences = ref.watch(userPreferencesProvider);
  final spotify = ref.watch(spotifyProvider);
  final endlessPlayback = preferences.endlessPlayback;

  useEffect(
    () {
      if (!endlessPlayback || auth[MusicPlatform.spotify]?.asData?.value == null) return null;

      void listener(int index) async {
        try {
          final playlist = ref.read(audioPlayerProvider);
          if (index != playlist.tracks.length - 1) return;

          final track = playlist.tracks.last;
          final query = "${track.title} Radio";

          if (preferences.audioSource == AudioSource.youtube) {
            final youtubeMusic = YoutubeMusicService();
            final results = await youtubeMusic.search(query);
            if (results.playlists.isEmpty) return;

            final radio = results.playlists.first;
            final tracks = await youtubeMusic.getPlaylistTracks(radio.id);
            
            await playback.addTracks(tracks);
          } else {
            // 使用 Spotify
            final searchResults = spotify.search
                .get(query, types: [SearchType.playlist]);
            
            final pages = await searchResults.first();
            final playlists = pages.first.items?.whereType<PlaylistSimple>();
            if (playlists == null || playlists.isEmpty) return;

            final artistName = track.artistName;
            
            final radio = playlists.firstWhere(
              (playlist) {
                final hasArtist = playlist.description?.contains(artistName) ?? false;
                return playlist.name == "${track.title} Radio" &&
                    hasArtist &&
                    playlist.owner?.displayName != "Spotify";
              },
              orElse: () => playlists.first,
            );
            final spotifyTracks = await spotify.playlists.getTracksByPlaylistId(radio.id!).all();
            
            // 使用 TrackFactory 转换 Spotify 曲目
            final sourceTracks = spotifyTracks.map((e) => 
              TrackFactory.createFromJson({
                ...e.toJson(),
                'track_type': 'spotify'
              })
            ).toList();

            await playback.addTracks(
              sourceTracks.where((e) => e.id != track.id).toList(),
            );
          }
        } catch (e, stack) {
          AppLogger.reportError(e, stack);
        }
      }

      if (playlist.index == playlist.medias.length - 1 &&
          audioPlayer.isPlaying) {
        listener(playlist.index);
      }

      final subscription =
          audioPlayer.currentIndexChangedStream.listen(listener);

      return subscription.cancel;
    },
    [
      auth,
      playback,
      playlist.medias,
      endlessPlayback,
      preferences.audioSource,
    ],
  );
}