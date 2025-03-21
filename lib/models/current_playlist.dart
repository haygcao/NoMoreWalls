import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/sourced_track.dart';

class CurrentPlaylist {
  List<SourceableTrack>? _tempTrack;
  List<SourceableTrack> tracks;
  String id;
  String name;
  String thumbnail;
  bool isLocal;

  CurrentPlaylist({
    required this.tracks,
    required this.id,
    required this.name,
    required this.thumbnail,
    this.isLocal = false,
  });

  static CurrentPlaylist fromJson(Map<String, dynamic> map, Ref ref) {
    return CurrentPlaylist(
      id: map["id"],
      tracks: List.castFrom<dynamic, SourceableTrack>(map["tracks"]
          .map(
            (track) => map["isLocal"] == true
                ? SourcedTrack.fromJson(track)
                : SourcedTrack.fromJson(track),
          )
          .toList()),
      name: map["name"],
      thumbnail: map["thumbnail"],
      isLocal: map["isLocal"],
    );
  }

  List<String> get trackIds => tracks.map((e) => e.id).toList();

  bool shuffle(SourceableTrack? topTrack) {
    if (_tempTrack == null) {
      _tempTrack = [...tracks];
      tracks = List.from(tracks)..shuffle();
      if (topTrack != null) {
        tracks.remove(topTrack);
        tracks.insert(0, topTrack);
      }
      return true;
    }
    return false;
  }

  bool unshuffle() {
    if (_tempTrack != null) {
      tracks = [..._tempTrack!];
      _tempTrack = null;
      return true;
    }
    return false;
  }

  CurrentPlaylist copyWith({
    List<SourceableTrack>? tracks,
    String? id,
    String? name,
    String? thumbnail,
    bool? isLocal,
  }) {
    return CurrentPlaylist(
      tracks: tracks ?? this.tracks,
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      isLocal: isLocal ?? this.isLocal,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "tracks": tracks.map((track) => track.toJson()).toList(),
      "thumbnail": thumbnail,
      "isLocal": isLocal,
    };
  }
}
