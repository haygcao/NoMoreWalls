import 'package:spotify/spotify.dart';
import 'package:spotube/utils/constants/app_markets.dart';

class MarketConverter {
  /// AppMarket 转 Spotify Market
  static Market toSpotifyMarket(AppMarket market) {
    return Market.values.firstWhere(
      (m) => m.name == market.code,
      orElse: () => Market.US,
    );
  }

  /// Spotify Market 转 AppMarket
  static AppMarket fromSpotifyMarket(Market market) {
    return AppMarket.fromString(market.name);
  }
}