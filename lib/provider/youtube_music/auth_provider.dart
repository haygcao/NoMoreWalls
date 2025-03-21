import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/services/cookie/cookie_manager.dart';
import 'package:spotube/models/youtube_music/credentials.dart';
import 'package:spotube/services/logger/logger.dart';

class YoutubeMusicAuthNotifier extends StateNotifier<AsyncValue<YoutubeMusicCredentials?>> {
  final CookieManager _cookieManager;

  YoutubeMusicAuthNotifier(this._cookieManager) : super(const AsyncValue.data(null)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final cookies = await _cookieManager.getCookies('youtube_music');
      if (cookies != null && cookies.isNotEmpty) {
        final credentials = await _validateCredentials(cookies);
        state = AsyncValue.data(credentials);
      }
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<YoutubeMusicCredentials?> _validateCredentials(Map<String, String> cookies) async {
    try {
      // 验证 cookies 是否有效
      final accessToken = cookies['accessToken'];
      final expirationStr = cookies['expiration'];
      
      if (accessToken == null || expirationStr == null) {
        return null;
      }

      final expiration = DateTime.parse(expirationStr);
      if (expiration.isBefore(DateTime.now())) {
        await logout();
        return null;
      }

      return YoutubeMusicCredentials(
        accessToken: accessToken,
        expiration: expiration,
        isAnonymous: false,
        cookies: cookies,
      );
    } catch (e) {
      AppLogger.reportError(e);
      return null;
    }
  }

  Future<void> login(Map<String, String> cookies) async {
    state = const AsyncValue.loading();
    try {
      final credentials = await _validateCredentials(cookies);
      if (credentials == null) {
        throw Exception('无效的认证信息');
      }

      await _cookieManager.saveCookies('youtube_music', cookies);
      state = AsyncValue.data(credentials);
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    try {
      await _cookieManager.clearCookies('youtube_music');
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    try {
      final cookies = await _cookieManager.getCookies('youtube_music');
      if (cookies == null || cookies.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      final credentials = await _validateCredentials(cookies);
      state = AsyncValue.data(credentials);
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      state = AsyncValue.error(e, stack);
    }
  }
}

final youtubeMusicAuthProvider = StateNotifierProvider<YoutubeMusicAuthNotifier, AsyncValue<YoutubeMusicCredentials?>>((ref) {
  return YoutubeMusicAuthNotifier(CookieManager());
});