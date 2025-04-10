import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generic service registry that manages platform-specific service implementations
class ServiceRegistry<T> {
  final Map<String, T> _services = {};
  final bool fallbackEnabled;
  final String _defaultPlatform = 'default';
  
  ServiceRegistry({this.fallbackEnabled = true});

  /// Register a service implementation for a specific platform
  void register(String platform, T service) {
    _services[platform] = service;
  }

  /// Register a default service implementation
  void registerDefault(T service) {
    register(_defaultPlatform, service);
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
  void removeService(String platform) {
    _services.remove(platform);
  }

  /// Clear all registered services
  void clear() {
    _services.clear();
  }
}

/// Creates a provider for a ServiceRegistry of type T
Provider<ServiceRegistry<T>> createServiceRegistryProvider<T>(
    {bool fallbackEnabled = true}) {
  return Provider<ServiceRegistry<T>>((ref) {
    return ServiceRegistry<T>(fallbackEnabled: fallbackEnabled);
  });
}

