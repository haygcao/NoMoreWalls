import 'package:hooks_riverpod/hooks_riverpod.dart';
// Use 'as' prefix to resolve the name conflict
import 'package:spotube/models/spotify/recommendation_seeds.dart' as spotify_seeds;

import 'package:spotube/models/spotify/sourceable_track_adapter.dart';
import 'package:spotube/models/unified/recommendation.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
// Delete the non-existing import
// import 'package:spotube/models/spotify/recommendation_attributes.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/utils/constants/app_markets.dart';
import 'package:spotube/utils/converters/market_converter.dart';

// 统一的推荐播放列表提供者
final unifiedRecommendationProvider = FutureProvider.autoDispose
    .family<List<SourceableTrack>, RecommendationSeeds>(
  (ref, input) async {
    final platform = ref.watch(currentMusicPlatformProvider);

    if (platform == MusicPlatform.youtubeMusic) {
      try {
        return await _getYouTubeMusicRecommendations(ref, input);
      } catch (e) {
        // 如果 YouTube Music 获取失败，尝试使用 Spotify
        return await _getSpotifyRecommendations(ref, input);
      }
    } else {
      return await _getSpotifyRecommendations(ref, input);
    }
  },
);

Future<List<SourceableTrack>> _getSpotifyRecommendations(
  Ref ref,
  RecommendationSeeds input,
) async {
  final spotify = ref.watch(spotifyProvider);
  final marketStr = ref.watch(
    userPreferencesProvider.select((s) => s.market),
  );
  final market = MarketConverter.toSpotifyMarket(AppMarket.fromString(marketStr));

  // 转换为 Spotify 的 GeneratePlaylistProviderInput
  final spotifyInput = spotify_seeds.GeneratePlaylistProviderInput(
    limit: input.limit,
    seedArtists: input.seedArtists,
    seedGenres: input.seedGenres,
    seedTracks: input.seedTracks,
    min: input.acousticness != null || input.danceability != null || input.energy != null
        ? spotify_seeds.RecommendationSeeds(
            acousticness: input.acousticness?.min,
            danceability: input.danceability?.min,
            energy: input.energy?.min,
            instrumentalness: input.instrumentalness?.min,
            key: input.key?.min?.toInt(),
            liveness: input.liveness?.min,
            loudness: input.loudness?.min,
            mode: input.mode?.min?.toInt(),
            popularity: input.popularity?.min?.toInt(),
            speechiness: input.speechiness?.min,
            tempo: input.tempo?.min,
            timeSignature: input.timeSignature?.min?.toInt(),
            valence: input.valence?.min,
          )
        : null,
    max: input.acousticness != null || input.danceability != null || input.energy != null
        ? spotify_seeds.RecommendationSeeds(
            acousticness: input.acousticness?.max,
            danceability: input.danceability?.max,
            energy: input.energy?.max,
            instrumentalness: input.instrumentalness?.max,
            key: input.key?.max?.toInt(),
            liveness: input.liveness?.max,
            loudness: input.loudness?.max,
            mode: input.mode?.max?.toInt(),
            popularity: input.popularity?.max?.toInt(),
            speechiness: input.speechiness?.max,
            tempo: input.tempo?.max,
            timeSignature: input.timeSignature?.max?.toInt(),
            valence: input.valence?.max,
          )
        : null,
    target: input.acousticness != null || input.danceability != null || input.energy != null
        ? spotify_seeds.RecommendationSeeds(
            acousticness: input.acousticness?.target,
            danceability: input.danceability?.target,
            energy: input.energy?.target,
            instrumentalness: input.instrumentalness?.target,
            key: input.key?.target?.toInt(),
            liveness: input.liveness?.target,
            loudness: input.loudness?.target,
            mode: input.mode?.target?.toInt(),
            popularity: input.popularity?.target?.toInt(),
            speechiness: input.speechiness?.target,
            tempo: input.tempo?.target,
            timeSignature: input.timeSignature?.target?.toInt(),
            valence: input.valence?.target,
          )
        : null,
  );

  final spotifyTracks = await ref.read(generatePlaylistProvider(spotifyInput).future);
  
  // 将 Spotify Track 转换为 SourceableTrack
  return spotifyTracks.map((track) => SpotifySourceableTrackAdapter(track)).toList();
}

Future<List<SourceableTrack>> _getYouTubeMusicRecommendations(
  Ref ref,
  RecommendationSeeds input,
) async {
  final youtubeMusic = ref.read(youtubeMusicProvider);
  
  // 使用种子曲目或艺术家获取推荐
  if (input.seedTracks != null && input.seedTracks!.isNotEmpty) {
    final recommendations = await youtubeMusic.getRecommendationsFromTrack(input.seedTracks!.first);
    return recommendations.tracks;
  } else if (input.seedArtists != null && input.seedArtists!.isNotEmpty) {
    final recommendations = await youtubeMusic.getRecommendationsFromArtist(input.seedArtists!.first);
    return recommendations.tracks;
  } else {
    // 如果没有种子，获取热门推荐
    final recommendations = await youtubeMusic.getRecommendations();
    return recommendations.first.tracks;
  }
}