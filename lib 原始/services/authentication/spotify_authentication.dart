import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/services/authentication/base_authentication.dart';

class SpotifyAuthenticationState extends MusicAuthenticationState {
  final String cookie;
  
  const SpotifyAuthenticationState({
    required super.accessToken,
    required super.expiration,
    required super.isAnonymous,
    required super.credentials,
    required this.cookie,
  });

  factory SpotifyAuthenticationState.fromAuthData(AuthenticationTableData? data) {
    if (data == null) {
      return SpotifyAuthenticationState(
        accessToken: '',
        expiration: DateTime.now(),
        isAnonymous: true,
        credentials: {},
        cookie: '',
      );
    }
    
    return SpotifyAuthenticationState(
      accessToken: data.accessToken.value,
      expiration: data.expiration,
      isAnonymous: false,
      credentials: {'cookie': data.cookie.value},
      cookie: data.cookie.value,
    );
  }
}

class SpotifyAuthenticationService implements MusicAuthenticationService {
  final Ref _ref;
  
  SpotifyAuthenticationService(this._ref);

  Future<MusicAuthenticationState?> getCurrentAuth() async {
    final authState = _ref.read(spotifyAuthenticationProvider);
    return authState.when(
      data: (data) => data != null 
          ? SpotifyAuthenticationState.fromAuthData(data)
          : null,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  @override
  Future<void> login(Map<String, String> credentials) async {
    final cookie = credentials['cookie'];
    if (cookie == null) {
      throw Exception('Cookie is required for Spotify authentication');
    }
    
    final notifier = _ref.read(spotifyAuthenticationProvider.notifier);
    await notifier.login(cookie);
  }

  @override
  Future<void> logout() async {
    final notifier = _ref.read(spotifyAuthenticationProvider.notifier);
    await notifier.logout();
  }

  @override
  Future<void> refresh() async {
    final notifier = _ref.read(spotifyAuthenticationProvider.notifier);
    await notifier.refreshCredentials();
  }

  @override
  Future<bool> validate() async {
    final authState = _ref.read(spotifyAuthenticationProvider);
    return authState.when(
      data: (data) {
        if (data == null) return false;
        return !data.isExpired;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }
}