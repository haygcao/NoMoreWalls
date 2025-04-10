import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base/interfaces/platform_service.dart';

/// Spotify platform service implementation
class SpotifyPlatformService extends PlatformService {
  @override
  String get platformId => 'spotify';

  @override
  String get platformName => 'Spotify';

  @override
  Map<String, dynamic> get platformConfig => {
        'apiVersion': '1.0.0',
        'requiresAuth': true,
      };

  @override
  Future<void> initialize() async {
    // Initialize Spotify-specific configurations and dependencies
  }

  @override
  Future<bool> isAvailable() async {
    // Check if Spotify service is available
    return true;
  }

  @override
  Future<void> dispose() async {
    // Clean up Spotify-specific resources
  }
}

/// Provider for the Spotify platform service
final spotifyPlatformServiceProvider = StateNotifierProvider<
    SpotifyPlatformServiceProvider, SpotifyPlatformService?>(
  (ref) => SpotifyPlatformServiceProvider(),
);

class SpotifyPlatformServiceProvider
    extends PlatformServiceProvider<SpotifyPlatformService> {
  @override
  Future<void> initialize() async {
    final service = SpotifyPlatformService();
    await initializeService(service);
  }
}
