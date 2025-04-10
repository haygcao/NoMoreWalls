import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';

/// PlaylistManager负责管理播放列表相关的功能
class PlaylistManager extends ChangeNotifier {
  final List<Map<String, dynamic>> _playlists = [];
  Map<String, List<String>> _playlistTracks = {};

  // 播放列表操作
  Future<void> createPlaylist(String name,
      {String? description, String? imageUrl}) async {
    final playlist = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _playlists.add(playlist);
    _playlistTracks[playlist['id']!] = [];
    notifyListeners();
  }

  Future<void> updatePlaylist(String playlistId,
      {String? name, String? description, String? imageUrl}) async {
    final index = _playlists.indexWhere((p) => p['id'] == playlistId);
    if (index != -1) {
      _playlists[index] = {
        ..._playlists[index],
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p['id'] == playlistId);
    _playlistTracks.remove(playlistId);
    notifyListeners();
  }

  // 播放列表曲目管理
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    if (_playlistTracks.containsKey(playlistId)) {
      if (!_playlistTracks[playlistId]!.contains(trackId)) {
        _playlistTracks[playlistId]!.add(trackId);
        notifyListeners();
      }
    }
  }

  Future<void> removeTrackFromPlaylist(
      String playlistId, String trackId) async {
    if (_playlistTracks.containsKey(playlistId)) {
      _playlistTracks[playlistId]!.remove(trackId);
      notifyListeners();
    }
  }

  Future<void> reorderPlaylistTracks(
      String playlistId, int oldIndex, int newIndex) async {
    if (_playlistTracks.containsKey(playlistId)) {
      final tracks = _playlistTracks[playlistId]!;
      final track = tracks.removeAt(oldIndex);
      tracks.insert(newIndex, track);
      notifyListeners();
    }
  }

  // 获取播放列表信息
  List<Map<String, dynamic>> get playlists => _playlists;

  List<String> getPlaylistTracks(String playlistId) {
    return _playlistTracks[playlistId] ?? [];
  }

  Map<String, dynamic>? getPlaylistById(String playlistId) {
    return _playlists.firstWhere(
      (p) => p['id'] == playlistId,
      orElse: () => <String, dynamic>{},
    );
  }
}

// Provider定义
final playlistManagerProvider = ChangeNotifierProvider<PlaylistManager>((ref) {
  return PlaylistManager();
});
