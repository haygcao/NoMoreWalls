import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/services/authentication/base_authentication.dart';
import 'package:spotube/services/authentication/spotify_authentication.dart';
import 'package:spotube/services/authentication/youtube_authentication.dart';



class AuthenticationProvider extends StateNotifier<Map<MusicPlatform, AsyncValue<MusicAuthenticationState?>>> {
  final Map<MusicPlatform, MusicAuthenticationService> _services;
  final Ref _ref;

  AuthenticationProvider(this._ref, this._services) : super({
    for (final platform in MusicPlatform.values)
      platform: const AsyncValue.data(null)
  }) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    for (final platform in MusicPlatform.values) {
      _refreshAuthState(platform);
    }
  }

  Future<void> _refreshAuthState(MusicPlatform platform) async {
    try {
      state = {
        ...state,
        platform: const AsyncValue.loading(),
      };

      final authState = await _services[platform]?.getCurrentAuth();
      
      state = {
        ...state,
        platform: AsyncValue.data(authState),
      };
    } catch (e, stack) {
      state = {
        ...state,
        platform: AsyncValue.error(e, stack),
      };
    }
  }

  Future<void> login(MusicPlatform platform, Map<String, String> credentials) async {
    try {
      state = {
        ...state,
        platform: const AsyncValue.loading(),
      };

      await _services[platform]?.login(credentials);
      await _refreshAuthState(platform);
    } catch (e, stack) {
      state = {
        ...state,
        platform: AsyncValue.error(e, stack),
      };
    }
  }

  Future<void> logout(MusicPlatform platform) async {
    try {
      state = {
        ...state,
        platform: const AsyncValue.loading(),
      };

      await _services[platform]?.logout();
      
      state = {
        ...state,
        platform: const AsyncValue.data(null),
      };
    } catch (e, stack) {
      state = {
        ...state,
        platform: AsyncValue.error(e, stack),
      };
    }
  }

  Future<void> refresh(MusicPlatform platform) async {
    try {
      await _services[platform]?.refresh();
      await _refreshAuthState(platform);
    } catch (e, stack) {
      state = {
        ...state,
        platform: AsyncValue.error(e, stack),
      };
    }
  }

  Future<bool> validate(MusicPlatform platform) async {
    try {
      return await _services[platform]?.validate() ?? false;
    } catch (e) {
      return false;
    }
  }
}

final authenticationProvider = StateNotifierProvider<AuthenticationProvider, Map<MusicPlatform, AsyncValue<MusicAuthenticationState?>>>((ref) {
  return AuthenticationProvider(
    ref,
    {
      MusicPlatform.spotify: SpotifyAuthenticationService(ref),
      MusicPlatform.youtubeMusic: YouTubeMusicAuthenticationService(ref),
    },
  );
});