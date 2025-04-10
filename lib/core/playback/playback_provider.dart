import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/core/playback/playback_service.dart';

enum PlaybackStatus { playing, paused, stopped, loading, error }

class PlaybackState {
  final PlaybackStatus status;
  final String? error;
  final Duration position;
  final Duration duration;
  final double volume;
  final List<String> queue;
  final int currentIndex;

  const PlaybackState({
    required this.status,
    this.error,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.queue = const [],
    this.currentIndex = -1,
  });

  PlaybackState copyWith({
    PlaybackStatus? status,
    String? error,
    Duration? position,
    Duration? duration,
    double? volume,
    List<String>? queue,
    int? currentIndex,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      error: error ?? this.error,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final PlaybackService _playbackService;

  PlaybackNotifier(this._playbackService)
      : super(const PlaybackState(status: PlaybackStatus.stopped)) {
    _playbackService.setOnPositionChanged(_onPositionChanged);
    _playbackService.setOnTrackComplete(_onTrackComplete);
  }

  void _onPositionChanged(Duration position) {
    state = state.copyWith(position: position);
  }

  void _onTrackComplete() {
    if (state.currentIndex < state.queue.length - 1) {
      playNext();
    } else {
      stop();
    }
  }

  Future<void> play(String url) async {
    try {
      state = state.copyWith(status: PlaybackStatus.loading);
      await _playbackService.play(url);
      state = state.copyWith(
        status: PlaybackStatus.playing,
        queue: [url],
        currentIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> playQueue(List<String> queue, {int startIndex = 0}) async {
    try {
      if (queue.isEmpty) return;
      state = state.copyWith(status: PlaybackStatus.loading);
      await _playbackService.play(queue[startIndex]);
      state = state.copyWith(
        status: PlaybackStatus.playing,
        queue: queue,
        currentIndex: startIndex,
      );
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> pause() async {
    try {
      await _playbackService.pause();
      state = state.copyWith(status: PlaybackStatus.paused);
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> resume() async {
    try {
      await _playbackService.resume();
      state = state.copyWith(status: PlaybackStatus.playing);
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> stop() async {
    try {
      await _playbackService.stop();
      state = state.copyWith(
        status: PlaybackStatus.stopped,
        position: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _playbackService.seek(position);
      state = state.copyWith(position: position);
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _playbackService.setVolume(volume);
      state = state.copyWith(volume: volume);
    } catch (e) {
      state = state.copyWith(
        status: PlaybackStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> playNext() async {
    if (state.currentIndex < state.queue.length - 1) {
      await playQueue(state.queue, startIndex: state.currentIndex + 1);
    }
  }

  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      await playQueue(state.queue, startIndex: state.currentIndex - 1);
    }
  }
}

final playbackProvider =
    StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  final playbackService = ref.watch(playbackServiceProvider);
  return PlaybackNotifier(playbackService);
});
