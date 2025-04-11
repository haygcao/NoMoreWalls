import 'package:flutter/foundation.dart';

/// Base class for all services in the application
///
/// Provides common functionality and lifecycle methods for services
abstract class BaseService {
  /// Service identifier
  String get serviceId;

  /// Service name for display
  String get serviceName;

  /// Service version
  String get serviceVersion;

  /// Platform this service is for (if applicable)
  String? get platform;

  /// Initialize the service
  ///
  /// This is called when the service is first registered
  Future<void> initialize() async {}

  /// Check if the service is available and ready to use
  Future<bool> isAvailable() async => true;

  /// Dispose the service and clean up resources
  ///
  /// This is called when the service is being unregistered
  Future<void> dispose() async {}

  /// Get service configuration
  Map<String, dynamic> getConfig() => {};

  /// Update service configuration
  Future<void> updateConfig(Map<String, dynamic> config) async {}

  /// Get service dependencies
  List<Type> getDependencies() => [];

  /// Get service status
  ServiceStatus getStatus() => ServiceStatus.available;
}

/// Enum representing the current status of a service
enum ServiceStatus {
  /// Service is initializing
  initializing,

  /// Service is available and ready to use
  available,

  /// Service is unavailable due to an error
  error,

  /// Service is unavailable because it's disabled
  disabled,

  /// Service is unavailable because it's not configured
  notConfigured
}
