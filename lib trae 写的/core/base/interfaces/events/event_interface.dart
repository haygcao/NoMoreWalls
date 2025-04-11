/// Base interface for all events in the application
abstract class EventInterface {
  /// Unique identifier for the event
  String get id;

  /// Timestamp when the event occurred
  DateTime get timestamp;

  /// Type of the event
  String get type;

  /// Source that generated the event
  String get source;

  /// Event data payload
  Map<String, dynamic> get data;

  /// Whether the event can be cancelled
  bool get isCancellable;

  /// Whether the event has been handled
  bool get isHandled;

  /// Whether the event propagation is stopped
  bool get isPropagationStopped;

  /// Mark the event as handled
  void markAsHandled();

  /// Stop event propagation
  void stopPropagation();

  /// Convert event to JSON representation
  Map<String, dynamic> toJson();
}

/// Interface for event handlers
abstract class EventHandlerInterface<T extends EventInterface> {
  /// Handle the event
  void handle(T event);

  /// Whether this handler can handle the given event
  bool canHandle(EventInterface event);
}

/// Interface for event dispatcher
abstract class EventDispatcherInterface {
  /// Dispatch an event
  void dispatch(EventInterface event);

  /// Add event handler
  void addHandler<T extends EventInterface>(EventHandlerInterface<T> handler);

  /// Remove event handler
  void removeHandler<T extends EventInterface>(
      EventHandlerInterface<T> handler);

  /// Clear all handlers
  void clearHandlers();
}
