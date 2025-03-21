import 'dart:async';

abstract class BaseEvent<T> {
  final String type;
  final T data;

  BaseEvent(this.type, this.data);

  Map<String, dynamic> toJson();
}

typedef EventCallback<T> = FutureOr<void> Function(T event);