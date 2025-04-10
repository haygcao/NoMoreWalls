import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base interface for all platform-specific services
abstract class PlatformService {
  /// The unique identifier for this platform
  String get platformId;

  /// The display name of this platform
  String get platformName;

  /// Initialize the platform service
  Future<void> initialize();

  /// Check if this platform service is available
  Future<bool> isAvailable();

  /// Get the platform-specific configuration
  Map<String, dynamic> get platformConfig;

  /// Clean up any resources used by this platform service
  Future<void> dispose();
}

/// Base class for platform-specific service providers
abstract class PlatformServiceProvider<T extends PlatformService>
    extends StateNotifier<T?> {
  PlatformServiceProvider() : super(null);

  /// Initialize and set the platform service
  Future<void> initializeService(T service) async {
    await service.initialize();
    state = service;
  }

  /// Get the current platform service instance
  T? get service => state;

  /// Check if the service is initialized
  bool get isInitialized => state != null;

  /// Clean up the service
  @override
  Future<void> dispose() async {
    if (state != null) {
      await state!.dispose();
      state = null;
    }
    super.dispose();
  }
}
