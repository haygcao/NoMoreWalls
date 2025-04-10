import 'package:spotify/spotify.dart' as spotify;
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/models/spotify/track.dart';  // 添加这个导入

class SpotifyPlaylistAdapter implements PlaylistBase {
  final spotify.PlaylistSimple _playlist;
  
  SpotifyPlaylistAdapter(this._playlist);
  
  @override
  String get id => _playlist.id!;
  
  @override
  String get name => _playlist.name!;
  
  @override
  String? get description => _playlist.description;
  
  @override
  String? get imageUrl => _playlist.images?.first.url;

  @override
  bool get isPublic => _playlist.public ?? false;

  @override
  bool get collaborative => _playlist.collaborative ?? false;

  @override
  int get totalTracks {
    // PlaylistSimple 可能没有直接的 tracks 属性
    // 我们需要检查它是否是 Playlist 类型，如果是则可以访问 tracks
    if (_playlist is spotify.Playlist) {
      return (_playlist as spotify.Playlist).tracks?.total ?? 0;
    }
    // 否则返回默认值或从其他属性获取
    return 0; // 或者从其他可用属性获取
  }

  @override
  String? get owner => _playlist.owner?.displayName;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'owner': owner,
    'isPublic': isPublic,
    'collaborative': collaborative,
    'totalTracks': totalTracks,
  };
}

class SpotifyArtistAdapter implements ArtistBase {
  final spotify.Artist _artist;
  
  SpotifyArtistAdapter(this._artist);
  
  @override
  String get id => _artist.id!;
  
  @override
  String get name => _artist.name!;
  
  @override
  String? get imageUrl => _artist.images?.first.url;
  
  @override
  String? get description => null; // Spotify artist 没有描述
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
  };
}

class SpotifyAlbumAdapter implements AlbumBase {
  final spotify.AlbumSimple _album;
  
  SpotifyAlbumAdapter(this._album);
  
  @override
  String get id => _album.id!;
  
  @override
  String get name => _album.name!;
  
  @override
  String? get imageUrl => _album.images?.first.url;
  
  @override
  List<String>? get artists => 
    _album.artists?.map((a) => a.name!).toList();
    
  @override
  DateTime? get releaseDate {
    if (_album.releaseDate == null) return null;
    try {
      return DateTime.parse(_album.releaseDate!);
    } catch (e) {
      // 处理不同的日期格式，例如只有年份的情况
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
  
  @override
  String? get albumType => _album.albumType?.name;
  
  @override
  @override
  List<SourceableTrack>? get tracks {
    if (_album is spotify.Album) {
      final fullAlbum = _album as spotify.Album;
      return fullAlbum.tracks?.map((trackSimple) {
        final track = spotify.Track()
          ..id = trackSimple.id
          ..name = trackSimple.name
          ..href = trackSimple.href
          ..uri = trackSimple.uri
          ..durationMs = trackSimple.duration?.inMilliseconds  // Convert Duration to milliseconds
          ..artists = trackSimple.artists
          ..type = trackSimple.type;
        return SpotifyTrack(track);
      }).toList();
    }
    return null;
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'artists': artists,
    'releaseDate': releaseDate?.toIso8601String(),
    'albumType': albumType,
    'tracks': tracks?.map((t) => t.toJson()).toList(),  // 添加 tracks
  };
}