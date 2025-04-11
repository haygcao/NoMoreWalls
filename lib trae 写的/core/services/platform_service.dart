import 'package:flutter/foundation.dart';

/// Abstract base class for platform-specific service implementations
@immutable
abstract class PlatformService {
  /// The name of the platform this service is for
  String get platformName;

  /// Initialize the service
  Future<void> initialize() async {}

  /// Check if the service is available
  Future<bool> isAvailable();

  /// Clean up resources when service is disposed
  Future<void> dispose() async {}

  /// Get service configuration
  Map<String, dynamic> getConfig() => {};

  /// Update service configuration
  Future<void> updateConfig(Map<String, dynamic> config) async {}
}
