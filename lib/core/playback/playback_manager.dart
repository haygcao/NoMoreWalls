import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';

/// PlaybackManager负责管理音乐播放的核心功能
class PlaybackManager extends ChangeNotifier {
  final Player _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<String> _playlist = [];
  int _currentIndex = -1;

  PlaybackManager() : _player = Player() {
    _initializePlayer();
  }

  void _initializePlayer() {
    _player.stream.position.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.stream.duration.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _player.stream.playing.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
  }

  // 播放控制
  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // 播放列表管理
  Future<void> setPlaylist(List<String> urls, {int startIndex = 0}) async {
    _playlist = urls;
    _currentIndex = startIndex;
    if (urls.isNotEmpty) {
      await _player.open(Media(urls[startIndex]));
    }
  }

  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _player.open(Media(_playlist[_currentIndex]));
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _player.open(Media(_playlist[_currentIndex]));
    }
  }

  // 状态获取
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  int get currentIndex => _currentIndex;
  List<String> get playlist => _playlist;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

// Provider定义
final playbackManagerProvider = ChangeNotifierProvider<PlaybackManager>((ref) {
  return PlaybackManager();
});
