import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';

import 'package:spotube/services/base/sourceable_track.dart';

import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/services/track_factory.dart';
import 'package:spotube/services/youtube_music/youtube_music_service.dart';

class AlbumTracksNotifier extends StateNotifier<AsyncValue<List<SourceableTrack>>> {
  final String albumId;
  final Ref ref;

  AlbumTracksNotifier({
    required this.albumId,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    fetchTracks();
  }

  Future<void> fetchTracks() async {
    state = const AsyncValue.loading();
    try {
      final preferences = ref.read(userPreferencesProvider);
      final audioSource = preferences.audioSource;
      
      List<SourceableTrack> sourceTracks = [];
      
      if (audioSource == AudioSource.youtube) {
        // 使用 YouTube Music 获取专辑曲目
        final youtubeMusic = YoutubeMusicService();
        final tracks = await youtubeMusic.getAlbumTracks(albumId);
        sourceTracks = tracks;
      } else {
        // 使用 Spotify 获取专辑曲目
        final spotify = ref.read(spotifyProvider);
        final tracks = await spotify.albums.tracks(albumId).all();
        sourceTracks = tracks.map((track) => 
          TrackFactory.createFromJson({
            ...track.toJson(),
            'track_type': 'spotify'
          })
        ).toList();
      }
      
      state = AsyncValue.data(sourceTracks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<SourceableTrack>> fetchAll() async {
    if (state.hasValue) {
      return state.value!;
    }
    await fetchTracks();
    return state.value ?? [];
  }
}

final albumTracksProvider = StateNotifierProvider.family<AlbumTracksNotifier, AsyncValue<List<SourceableTrack>>, String>(
  (ref, albumId) => AlbumTracksNotifier(
    albumId: albumId,
    ref: ref,
  ),
);