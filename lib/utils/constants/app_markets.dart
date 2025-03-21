

import 'country_codes.dart';

/// 市场/地域类
class AppMarket {
  final String code;
  final String displayName;

  const AppMarket._(this.code, this.displayName);

  /// 获取所有支持的市场
  static final values = countryCodesMap.entries
      .map((e) => AppMarket._(e.key, e.value))
      .toList();

  /// 获取默认市场
  static const defaultMarket = 'US';

  /// 从字符串获取市场
  static AppMarket fromString(String value) {
    return values.firstWhere(
      (market) => market.code == value,
      orElse: () => values.firstWhere((m) => m.code == defaultMarket),
    );
  }

  @override
  String toString() => code;
}

/// 所有支持的市场列表，用于 UI 显示
final appMarkets = AppMarket.values;