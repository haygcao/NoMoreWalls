part of '../spotify.dart';

final artistTopTracksProvider =
    FutureProvider.autoDispose.family<List<Track>, String>(
  (ref, artistId) async {
    ref.cacheFor();

    final spotify = ref.watch(spotifyProvider);
    final marketStr = ref.watch(userPreferencesProvider.select((s) => s.market));
    final market = MarketConverter.toSpotifyMarket(AppMarket.fromString(marketStr));
    final tracks = await spotify.artists.topTracks(artistId, market);

    return tracks.toList();
  },
);
