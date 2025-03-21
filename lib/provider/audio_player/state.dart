import 'package:media_kit/media_kit.dart';

import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class AudioPlayerState {
  final bool playing;
  final PlaylistMode loopMode;
  final bool shuffled;
  final Playlist playlist;
  final List<SourceableTrack> tracks;
  final List<String> collections;

  AudioPlayerState({
    required this.playing,
    required this.loopMode,
    required this.shuffled,
    required this.playlist,
    required this.collections,
    List<SourceableTrack>? tracks,
  }) : tracks = tracks ?? [];  // 简化 tracks 初始化

  // 修改工厂方法，将 ref 作为可选参数
  factory AudioPlayerState.fromJson(Map<String, dynamic> json) {
    return AudioPlayerState(
      playing: json['playing'],
      loopMode: PlaylistMode.values.firstWhere(
        (e) => e.name == json['loopMode'],
        orElse: () => audioPlayer.loopMode,
      ),
      shuffled: json['shuffled'],
      playlist: Playlist(
        json['playlist']['medias']
            .map((media) => Media(
                  media['uri'],
                  extras: media['extras'],
                  httpHeaders: media['httpHeaders'],
                ))
            .cast<Media>()
            .toList(),
        index: json['playlist']['index'],
      ),
      collections: List<String>.from(json['collections']),
    );
  }

  // 修改 copyWith 方法，移除 ref 参数
  AudioPlayerState copyWith({
    bool? playing,
    PlaylistMode? loopMode,
    bool? shuffled,
    Playlist? playlist,
    List<String>? collections,
    List<SourceableTrack>? tracks,
  }) {
    return AudioPlayerState(
      playing: playing ?? this.playing,
      loopMode: loopMode ?? this.loopMode,
      shuffled: shuffled ?? this.shuffled,
      playlist: playlist ?? this.playlist,
      collections: collections ?? this.collections,
      tracks: tracks ?? this.tracks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playing': playing,
      'loopMode': loopMode.name,
      'shuffled': shuffled,
      'playlist': {
        'medias': playlist.medias
            .map((media) => {
                  'uri': media.uri,
                  'extras': media.extras,
                  'httpHeaders': media.httpHeaders,
                })
            .toList(),
        'index': playlist.index,
      },
      'collections': collections,
    };
  }

  SourceableTrack? get activeTrack {
    if (playlist.index == -1) return null;
    return tracks.elementAtOrNull(playlist.index);
  }

  Media? get activeMedia {
    if (playlist.index == -1 || playlist.medias.isEmpty) return null;
    return playlist.medias.elementAt(playlist.index);
  }

  bool containsTrack(SourceableTrack track) {
    return tracks.any((t) => t.id == track.id);
  }

  bool containsTracks(List<SourceableTrack> tracks) {
    return tracks.every(containsTrack);
  }

  bool containsCollection(String collectionId) {
    return collections.contains(collectionId);
  }
}
