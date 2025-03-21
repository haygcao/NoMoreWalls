part of '../spotify.dart';

final viewProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, viewName) async {
    final customSpotify = ref.watch(customSpotifyEndpointProvider);
    final marketStr = ref.watch(
      userPreferencesProvider.select((s) => s.market),
    );
    final locale = ref.watch(
      userPreferencesProvider.select((s) => s.locale),
    );

    final market = AppMarket.fromString(marketStr);

    return customSpotify.getView(
      viewName,
      market: MarketConverter.toSpotifyMarket(market),
      locale: Intl.canonicalizedLocale(locale.toString()),
    );
  },
);
