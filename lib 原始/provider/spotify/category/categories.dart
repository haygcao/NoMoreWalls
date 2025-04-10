part of '../spotify.dart';

final categoriesProvider = FutureProvider(
  (ref) async {
    final spotify = ref.watch(spotifyProvider);
    final marketStr = ref.watch(userPreferencesProvider.select((s) => s.market));
    final market = MarketConverter.toSpotifyMarket(AppMarket.fromString(marketStr));
    final locale = ref.watch(userPreferencesProvider.select((s) => s.locale));
    
    final categories = await spotify.categories
        .list(
          country: market,
          locale: Intl.canonicalizedLocale(
            locale.toString(),
          ),
        )
        .all();

    return categories.toList()..shuffle();
  },
);
