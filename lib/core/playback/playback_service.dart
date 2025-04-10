import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

class PlaybackService {
  static final instance = PlaybackService._();
  PlaybackService._() {
    _player = Player();
    _player.stream.position.listen(_onPositionChanged);
    _player.stream.completed.listen((_) => _onTrackComplete?.call());
  }

  late final Player _player;
  Function()? _onTrackComplete;
  Function(Duration)? _onPositionChanged;

  Future<void> play(String url) async {
    await _player.open(Media(url));
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume * 100);
  }

  void setOnTrackComplete(Function() callback) {
    _onTrackComplete = callback;
  }

  void setOnPositionChanged(Function(Duration) callback) {
    _onPositionChanged = callback;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  bool get isPlaying => _player.state.playing;
  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
}

final playbackServiceProvider = Provider<PlaybackService>((ref) {
  return PlaybackService.instance;
});
