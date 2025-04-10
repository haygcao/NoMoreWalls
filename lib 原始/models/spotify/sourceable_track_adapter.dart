
import 'package:spotify/spotify.dart';
import 'package:spotube/models/spotify/track_adapter.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class SpotifySourceableTrackAdapter extends SpotifyTrackAdapter implements SourceableTrack {
  // Store the track reference for direct access
  final Track track;
  
  const SpotifySourceableTrackAdapter(this.track) : super(track);
  
  @override
  String? get albumId => track.album?.id;
  
  @override
  String? get thumbnailUrl => track.album?.images?.isNotEmpty == true 
      ? track.album!.images!.first.url 
      : null;
  
  @override
  String get artistId => track.artists?.isNotEmpty == true ? track.artists!.first.id ?? '' : '';
  
  @override
  String get artistName => super.artistName ?? '';
  
  @override
  Duration get duration => super.duration ?? Duration.zero;
  
  @override
  String getDescription() {
    final artists = track.artists?.map((a) => a.name).join(', ') ?? '';
    final album = albumName ?? '';
    return [artists, album].where((e) => e.isNotEmpty).join(' • ');
  }
  
  @override
  String getDisplayName() {
    return title;
  }
  
  @override
  String getSearchTerm() {
    final artists = track.artists?.map((a) => a.name).join(' ') ?? '';
    return '$title $artists';
  }
  
  // Fix the return type to match SourceableTrack interface
  @override
  Map<String, dynamic> toMediaItem() {
    return {
      'id': id,
      'title': title,
      'album': albumName,
      'artist': artistName,
      'duration': duration.inMilliseconds,
      'artUri': thumbnailUrl,
      'albumId': albumId,
      'artistId': artistId,
      'source': source,
    };
  }
  
  @override
  String get source => 'spotify';
  
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'albumId': albumId,
    'artistId': artistId,
    'thumbnailUrl': thumbnailUrl,
    'source': source,
  };
}