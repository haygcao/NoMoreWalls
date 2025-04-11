import 'package:flutter/foundation.dart';

/// Represents the current status of a platform service
@immutable
class ServiceStatus {
  final bool isAvailable;
  final DateTime lastChecked;
  final String? errorMessage;
  final int retryCount;

  const ServiceStatus({
    required this.isAvailable,
    required this.lastChecked,
    this.errorMessage,
    this.retryCount = 0,
  });

  ServiceStatus copyWith({
    bool? isAvailable,
    DateTime? lastChecked,
    String? errorMessage,
    int? retryCount,
  }) {
    return ServiceStatus(
      isAvailable: isAvailable ?? this.isAvailable,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'isAvailable': isAvailable,
        'lastChecked': lastChecked.toIso8601String(),
        'errorMessage': errorMessage,
        'retryCount': retryCount,
      };

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      isAvailable: json['isAvailable'] ?? false,
      lastChecked: DateTime.parse(json['lastChecked']),
      errorMessage: json['errorMessage'],
      retryCount: json['retryCount'] ?? 0,
    );
  }
}
