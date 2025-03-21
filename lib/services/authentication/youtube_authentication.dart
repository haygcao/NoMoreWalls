import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/youtube_music/credentials.dart';
import 'package:spotube/provider/youtube_music/auth_provider.dart';
import 'package:spotube/services/authentication/base_authentication.dart';


class YouTubeMusicAuthenticationState extends MusicAuthenticationState {
  final Map<String, String> cookies;
  
  const YouTubeMusicAuthenticationState({
    required super.accessToken,
    required super.expiration,
    required super.isAnonymous,
    required super.credentials,
    required this.cookies,
  });

  factory YouTubeMusicAuthenticationState.fromCredentials(YoutubeMusicCredentials? credentials) {
    if (credentials == null) {
      return YouTubeMusicAuthenticationState(
        accessToken: '',
        expiration: DateTime.now(),
        isAnonymous: true,
        credentials: {},
        cookies: {},
      );
    }
    
    return YouTubeMusicAuthenticationState(
      accessToken: credentials.accessToken,
      expiration: credentials.expiration,
      isAnonymous: credentials.isAnonymous,
      credentials: credentials.cookies,
      cookies: credentials.cookies,
    );
  }
}

class YouTubeMusicAuthenticationService implements MusicAuthenticationService {
  final Ref _ref;
  
  YouTubeMusicAuthenticationService(this._ref);

  Future<MusicAuthenticationState?> getCurrentAuth() async {
    final authState = _ref.read(youtubeMusicAuthProvider);
    return authState.when(
      data: (credentials) => credentials != null 
          ? YouTubeMusicAuthenticationState.fromCredentials(credentials)
          : null,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  @override
  Future<void> login(Map<String, String> credentials) async {
    final notifier = _ref.read(youtubeMusicAuthProvider.notifier);
    await notifier.login(credentials);
  }

  @override
  Future<void> logout() async {
    final notifier = _ref.read(youtubeMusicAuthProvider.notifier);
    await notifier.logout();
  }

  @override
  Future<void> refresh() async {
    final notifier = _ref.read(youtubeMusicAuthProvider.notifier);
    await notifier.refresh();
  }

  @override
  Future<bool> validate() async {
    final authState = _ref.read(youtubeMusicAuthProvider);
    return authState.when(
      data: (credentials) {
        if (credentials == null) return false;
        return !credentials.expiration.isBefore(DateTime.now());
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }
}