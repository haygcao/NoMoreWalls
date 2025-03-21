import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/provider/spotify/custom_spotify_endpoint_provider.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/utils/constants/app_markets.dart';
import 'package:spotube/utils/converters/market_converter.dart';

final homeViewProvider = FutureProvider((ref) async {
  final countryStr = ref.watch(
    userPreferencesProvider.select((s) => s.market),
  );
  final spTCookie = ref.watch(
    spotifyAuthenticationProvider.select((s) => s.asData?.value?.getCookie("sp_t")),
  );

  if (spTCookie == null) return null;

  final spotify = ref.watch(customSpotifyEndpointProvider);
  final market = AppMarket.fromString(countryStr);

  return spotify.getHomeFeed(
    country: MarketConverter.toSpotifyMarket(market),
    spTCookie: spTCookie,
  );
});
