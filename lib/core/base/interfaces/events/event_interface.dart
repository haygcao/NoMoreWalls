import 'package:flutter/foundation.dart';

/// Interface for application events
///
/// Defines the base structure for all events in the application
@immutable
abstract class EventInterface {
  /// Unique identifier for the event type
  String get eventType;

  /// Timestamp when the event occurred
  DateTime get timestamp;

  /// Source that generated the event
  String get source;

  /// Event data payload
  Map<String, dynamic> get data;

  /// Convert the event to a JSON representation
  Map<String, dynamic> toJson();
}

/// Interface for event listeners
///
/// Defines the structure for objects that can listen to events
abstract class EventListenerInterface {
  /// Handle an incoming event
  void onEvent(EventInterface event);

  /// Get the event types this listener is interested in
  List<String> get interestedEventTypes;
}

/// Interface for event dispatchers
///
/// Defines the structure for objects that can dispatch events
abstract class EventDispatcherInterface {
  /// Dispatch an event to all registered listeners
  void dispatchEvent(EventInterface event);

  /// Register a listener for events
  void registerListener(EventListenerInterface listener);

  /// Unregister a listener
  void unregisterListener(EventListenerInterface listener);

  /// Unregister all listeners
  void clearListeners();
}
