

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

/// 将市场代码转换为显示名称的辅助函数
String getMarketDisplayName(String? code) {
  if (code == null) return "未知";
  
  final market = AppMarket.values.firstWhere(
    (market) => market.code == code,
    orElse: () => AppMarket.values.firstWhere(
      (m) => m.code == AppMarket.defaultMarket
    ),
  );
  
  return market.displayName;
}