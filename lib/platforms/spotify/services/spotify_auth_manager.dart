import 'package:spotify/spotify.dart';
import '../../../core/auth/auth_manager.dart';

class SpotifyAuthManager extends AuthManager {
  SpotifyApi? _spotifyApi;
  SpotifyApi? get spotifyApi => _spotifyApi;

  @override
  Future<void> login(Map<String, dynamic> credentials) async {
    try {
      final accessToken = credentials['accessToken'] as String;
      updateState(AuthState(
        status: AuthenticationStatus.loading,
        accessToken: accessToken,
      ));

      _spotifyApi = SpotifyApi(
        SpotifyApiCredentials(
          '', // Client ID will be injected from env
          '', // Client Secret will be injected from env
          accessToken: accessToken,
        ),
      );

      updateState(AuthState(
        status: AuthenticationStatus.authenticated,
        accessToken: accessToken,
        credentials: credentials,
      ));
    } catch (e) {
      updateState(AuthState(
        status: AuthenticationStatus.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> logout() async {
    _spotifyApi = null;
    updateState(const AuthState(
      status: AuthenticationStatus.unauthenticated,
    ));
  }

  @override
  Future<void> refreshToken(String newAccessToken) async {
    await login({'accessToken': newAccessToken});
  }
}
