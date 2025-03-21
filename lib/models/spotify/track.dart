import 'package:spotify/spotify.dart' as spotify;
import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class SpotifyTrack implements BaseTrack, SourceableTrack {
  final spotify.Track _track;

  SpotifyTrack(this._track);

  @override
  String get id => _track.id!;

  @override
  String get title => _track.name!;

  @override
  String get artistName => _track.artists?.first.name ?? '';

  @override
  String? get albumName => _track.album?.name;

  @override
  Duration get duration => Duration(milliseconds: _track.durationMs ?? 0);

  @override
  String? get thumbnailUrl => _track.album?.images?.first.url;

  @override
  String? get artistId => _track.artists?.first.id;

  @override
  String? get albumId => _track.album?.id;

  @override
  Map<String, dynamic> toJson() => _track.toJson();

  @override
  String getDisplayName() {
    final artists = _track.artists?.map((a) => a.name).whereType<String>().join(", ") ?? '';
    return "$title - $artists";
  }

  @override
  String getDescription() {
    return albumName != null ? "专辑: $albumName" : "";
  }

  @override
  Map<String, dynamic> toMediaItem() {
    return {
      'id': id,
      'title': title,
      'artist': artistName,
      'album': albumName,
      'duration': duration.inMilliseconds,
      'artUri': thumbnailUrl,
    };
  }

  @override
  String getSearchTerm() {
    final artists = _track.artists?.map((a) => a.name).whereType<String>().join(", ") ?? '';
    return "$title - $artists";
  }

  // 添加一个工厂方法用于从原始 Track 创建
  factory SpotifyTrack.fromTrack(spotify.Track track) {
    return SpotifyTrack(track);
  }
}