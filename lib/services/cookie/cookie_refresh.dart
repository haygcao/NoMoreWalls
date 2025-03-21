import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'cookie_manager.dart';

class CookieRefreshService {
  final CookieManager _cookieManager;
  Timer? _refreshTimer;

  CookieRefreshService() : _cookieManager = CookieManager();

  void startRefresh(String service, Duration interval, Future<void> Function() refreshCallback) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) async {
      await refreshCallback();
    });
  }

  void stopRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

final cookieRefreshProvider = Provider((ref) => CookieRefreshService());