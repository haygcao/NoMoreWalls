import 'package:spotube/models/youtube_music/album.dart';
import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class YoutubeMusicAlbumAdapter implements AlbumBase {
  final YoutubeMusicAlbum _album;
  
  const YoutubeMusicAlbumAdapter(this._album);

  @override
  String get id => _album.id;

  @override
  String get name => _album.title;

  @override
  String? get imageUrl => _album.thumbnailUrl;

  @override
  List<String>? get artists => [_album.artistName];

  @override
  DateTime? get releaseDate => _album.releaseDate;

  @override
  String? get albumType {
    // 基于曲目数量推断专辑类型
    if (_album.tracks.length <= 2) {
      return 'single';
    } else if (_album.tracks.length <= 6) {
      return 'ep';
    } else {
      return 'album';
    }
  }

  @override
  List<SourceableTrack>? get tracks => _album.tracks;

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