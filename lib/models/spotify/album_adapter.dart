import 'package:spotify/spotify.dart' as spotify;
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/models/spotify/track.dart';

class SpotifyAlbumAdapter implements AlbumBase {
  final spotify.Album _album;
  
  const SpotifyAlbumAdapter(this._album);

  @override
  String get id => _album.id!;

  @override
  String get name => _album.name!;

  @override
  String? get imageUrl => _album.images?.isNotEmpty == true ? _album.images!.first.url : null;

  @override
  List<String>? get artists => _album.artists?.map((artist) => artist.name!).toList();

  @override
  DateTime? get releaseDate {
    if (_album.releaseDate == null) return null;
    try {
      return DateTime.parse(_album.releaseDate!);
    } catch (e) {
      // Handle different date formats, e.g., year-only
      if (_album.releaseDatePrecision == 'year' && _album.releaseDate != null) {
        return DateTime(int.parse(_album.releaseDate!), 1, 1);
      } else if (_album.releaseDatePrecision == 'month' && _album.releaseDate != null) {
        final parts = _album.releaseDate!.split('-');
        if (parts.length >= 2) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
        }
      }
      return null;
    }
  }

  // Fix: Convert AlbumType to String
  @override
  String? get albumType => _album.albumType?.name;

  // Fix: Correctly access tracks from Spotify Album
  @override
  List<SourceableTrack>? get tracks {
    if (_album.tracks == null) return null;
    
    // _album.tracks is already an Iterable<TrackSimple>
    return _album.tracks?.map((trackSimple) {
      // Create a Track from TrackSimple
      final track = spotify.Track()
        ..id = trackSimple.id
        ..name = trackSimple.name
        ..href = trackSimple.href
        ..uri = trackSimple.uri
        ..durationMs = trackSimple.durationMs
        ..artists = trackSimple.artists
        ..album = _album
        ..type = trackSimple.type;
      return SpotifyTrack(track);
    }).toList();
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'artists': artists,
    'releaseDate': releaseDate?.toIso8601String(),
    'albumType': albumType,
    'tracks': tracks?.map((track) => track.toJson()).toList(),
  };
}