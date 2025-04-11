import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spotube/core/services/platform_service.dart';

import 'service_config.dart';
import 'service_status.dart';

typedef ServiceFactory<T extends PlatformService> = Future<T> Function();

/// A generic service registry that manages platform-specific service implementations
class ServiceRegistry<T extends PlatformService> {
  final Map<String, T> _services = {};
  final Map<String, ServiceConfig> _configs = {};
  final Map<String, ServiceStatus> _status = {};
  final Map<String, ServiceFactory<T>> _factories = {};
  final bool fallbackEnabled;
  final String _defaultPlatform = 'default';
  final List<Function(T service)> _onServiceRegistered = [];
  final List<Function(String platform)> _onServiceRemoved = [];
  final List<Function(String platform, ServiceStatus status)> _onStatusChanged =
      [];
  static const Duration _healthCheckInterval = Duration(minutes: 1);
  Timer? _healthCheckTimer;

  ServiceRegistry({this.fallbackEnabled = true}) {
    _startHealthCheck();
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (timer) async {
      for (var entry in _services.entries) {
        try {
          final isAvailable = await entry.value.isAvailable();
          final newStatus = ServiceStatus(
            isAvailable: isAvailable,
            lastChecked: DateTime.now(),
            errorMessage: null,
          );
          _updateServiceStatus(entry.key, newStatus);
        } catch (e) {
          _updateServiceStatus(
            entry.key,
            ServiceStatus(
              isAvailable: false,
              lastChecked: DateTime.now(),
              errorMessage: e.toString(),
            ),
          );
        }
      }
    });
  }

  void _updateServiceStatus(String platform, ServiceStatus status) {
    _status[platform] = status;
    for (var callback in _onStatusChanged) {
      callback(platform, status);
    }
  }

  /// Register a service implementation for a specific platform
  Future<void> register(String platform, T service,
      {ServiceConfig? config}) async {
    try {
      // Initialize the service before registration
      await service.initialize();

      // Verify service availability
      if (!await service.isAvailable()) {
        throw Exception('Service for platform $platform is not available');
      }

      _services[platform] = service;
      if (config != null) {
        _configs[platform] = config;
      }
      _updateServiceStatus(
        platform,
        ServiceStatus(
          isAvailable: true,
          lastChecked: DateTime.now(),
          errorMessage: null,
        ),
      );

      // Notify listeners
      for (var callback in _onServiceRegistered) {
        callback(service);
      }
    } catch (e) {
      throw Exception('Failed to register service for platform $platform: $e');
    }
  }

  /// Register a default service implementation
  Future<void> registerDefault(T service, {ServiceConfig? config}) async {
    await register(_defaultPlatform, service, config: config);
  }

  /// Register a service factory for a specific platform
  void registerFactory(String platform, ServiceFactory<T> factory) {
    _factories[platform] = factory;
  }

  /// Auto-discover and register services using registered factories
  Future<void> autoDiscoverAndRegister() async {
    for (final entry in _factories.entries) {
      if (!hasService(entry.key)) {
        try {
          final service = await entry.value();
          await register(entry.key, service);
        } catch (e) {
          print('Failed to load service for platform ${entry.key}: $e');
          _updateServiceStatus(
            entry.key,
            ServiceStatus(
              isAvailable: false,
              lastChecked: DateTime.now(),
              errorMessage: e.toString(),
              retryCount: 0,
            ),
          );
        }
      }
    }
  }

  /// Get service for specific platform
  T? getService(String platform) {
    final service = _services[platform];
    if (service != null) return service;

    // Fallback to default service if enabled
    if (fallbackEnabled) {
      return _services[_defaultPlatform];
    }
    return null;
  }

  /// Get all registered services
  Map<String, T> get services => Map.unmodifiable(_services);

  /// Get the default service
  T? get defaultService => _services[_defaultPlatform];

  /// Check if a platform has a registered service
  bool hasService(String platform) => _services.containsKey(platform);

  /// Remove service for a specific platform
  Future<void> removeService(String platform) async {
    final service = _services[platform];
    if (service != null) {
      await service.dispose();
      _services.remove(platform);
      _configs.remove(platform);
      _status.remove(platform);

      // Notify listeners
      for (var callback in _onServiceRemoved) {
        callback(platform);
      }
    }
  }

  /// Clear all registered services
  Future<void> clear() async {
    for (var platform in List.from(_services.keys)) {
      await removeService(platform);
    }
  }

  /// Add a listener for service registration events
  void addOnServiceRegisteredListener(Function(T service) callback) {
    _onServiceRegistered.add(callback);
  }

  /// Add a listener for service removal events
  void addOnServiceRemovedListener(Function(String platform) callback) {
    _onServiceRemoved.add(callback);
  }

  /// Remove a listener for service registration events
  void removeOnServiceRegisteredListener(Function(T service) callback) {
    _onServiceRegistered.remove(callback);
  }

  /// Remove a listener for service removal events
  void removeOnServiceRemovedListener(Function(String platform) callback) {
    _onServiceRemoved.remove(callback);
  }

  void addOnStatusChangedListener(
      Function(String platform, ServiceStatus status) callback) {
    _onStatusChanged.add(callback);
  }

  void removeOnStatusChangedListener(
      Function(String platform, ServiceStatus status) callback) {
    _onStatusChanged.remove(callback);
  }

  ServiceConfig? getServiceConfig(String platform) => _configs[platform];
  ServiceStatus? getServiceStatus(String platform) => _status[platform];

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    clear();
  }
}

/// Creates a provider for a ServiceRegistry of type T
Provider<ServiceRegistry<T>>
    createServiceRegistryProvider<T extends PlatformService>(
        {bool fallbackEnabled = true}) {
  return Provider<ServiceRegistry<T>>((ref) {
    return ServiceRegistry<T>(fallbackEnabled: fallbackEnabled);
  });
}
