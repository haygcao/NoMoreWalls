import 'package:spotify/spotify.dart';
import 'package:spotube/services/base/base_track.dart';

class SpotifyTrackAdapter implements BaseTrack {
  final Track _track;
  
  const SpotifyTrackAdapter(this._track);

  @override
  String get id => _track.id!;

  @override
  String get title => _track.name!;

  @override
  String? get artistName => _track.artists?.first.name;

  @override
  String? get albumName => _track.album?.name;

  @override
  Duration? get duration => _track.duration;
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artistName': artistName,
    'albumName': albumName,
    'duration': duration?.inMilliseconds,
  };
}