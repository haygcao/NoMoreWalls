import 'package:flutter/foundation.dart';

/// Configuration for a platform service
@immutable
class ServiceConfig {
  final Map<String, dynamic> parameters;
  final List<String> dependencies;
  final Duration retryInterval;
  final int maxRetries;

  const ServiceConfig({
    this.parameters = const {},
    this.dependencies = const [],
    this.retryInterval = const Duration(seconds: 30),
    this.maxRetries = 3,
  });

  ServiceConfig copyWith({
    Map<String, dynamic>? parameters,
    List<String>? dependencies,
    Duration? retryInterval,
    int? maxRetries,
  }) {
    return ServiceConfig(
      parameters: parameters ?? this.parameters,
      dependencies: dependencies ?? this.dependencies,
      retryInterval: retryInterval ?? this.retryInterval,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }

  Map<String, dynamic> toJson() => {
        'parameters': parameters,
        'dependencies': dependencies,
        'retryInterval': retryInterval.inMilliseconds,
        'maxRetries': maxRetries,
      };

  factory ServiceConfig.fromJson(Map<String, dynamic> json) {
    return ServiceConfig(
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      retryInterval: Duration(milliseconds: json['retryInterval'] ?? 30000),
      maxRetries: json['maxRetries'] ?? 3,
    );
  }
}
