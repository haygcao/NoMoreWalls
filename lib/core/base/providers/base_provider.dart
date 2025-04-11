import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/base_service.dart';

/// Base provider class for all providers in the application
///
/// Provides common functionality for providers
abstract class BaseProvider<T extends BaseService>
    extends StateNotifier<AsyncValue<T?>> {
  /// The service instance
  T? _service;

  /// Create a new base provider
  BaseProvider() : super(const AsyncValue.loading());

  /// Initialize the provider with a service
  Future<void> initialize(T service) async {
    state = const AsyncValue.loading();
    try {
      _service = service;
      await _service!.initialize();
      state = AsyncValue.data(_service);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Get the service instance
  T get service {
    final value = _service;
    if (value == null) {
      throw Exception('Service not initialized');
    }
    return value;
  }

  /// Check if the service is initialized
  bool get isInitialized => _service != null;

  /// Dispose the provider and clean up resources
  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}
