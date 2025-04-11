import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/platform_service.dart';

import '../service_registry.dart';

/// A service loader that handles the discovery and registration of platform services
class PlatformServiceLoader {
  final Ref _ref;
  final Map<Type, ServiceRegistry> _registries = {};

  PlatformServiceLoader(this._ref);

  /// Register a platform service with its appropriate registry
  void registerPlatformService<T extends PlatformService>(T service) {
    final registry = _getOrCreateRegistry<T>();
    registry.register(service.platformId, service);
  }

  /// Get or create a service registry for a specific service type
  ServiceRegistry<T> _getOrCreateRegistry<T extends PlatformService>() {
    if (!_registries.containsKey(T)) {
      final registry = ServiceRegistry<T>();
      _registries[T] = registry;
    }
    return _registries[T] as ServiceRegistry<T>;
  }

  /// Get a service registry for a specific service type
  ServiceRegistry<T>? getRegistry<T extends PlatformService>() {
    return _registries[T] as ServiceRegistry<T>?;
  }

  /// Get a platform service instance
  T? getService<T extends PlatformService>(String platformId) {
    final registry = getRegistry<T>();
    return registry?.getService(platformId);
  }

  /// Get all registered services of a specific type
  Map<String, T> getServices<T extends PlatformService>() {
    final registry = getRegistry<T>();
    return registry?.services ?? {};
  }

  /// Clear all registered services
  void clear() {
    for (final registry in _registries.values) {
      registry.clear();
    }
    _registries.clear();
  }
}

/// Provider for the PlatformServiceLoader
final platformServiceLoaderProvider = Provider((ref) {
  return PlatformServiceLoader(ref);
});
