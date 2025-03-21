
import 'dart:io';
import 'dart:typed_data';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class LocalTrack implements SourceableTrack {
  final String path;
  @override
  final String id;
  @override
  final String title;
  @override
  final String artistName;
  @override
  final String? albumName;
  @override
  final Duration duration;
  @override
  final String? thumbnailUrl;
  @override
  final String? artistId;
  @override
  final String? albumId;

  LocalTrack({
    required this.path,
    required this.title,
    required this.artistName,
    this.albumName,
    required this.duration,
    this.thumbnailUrl,
    String? id,
    this.artistId,
    this.albumId,
  }) : id = id ?? path;

  @override
  String getDisplayName() => "$title - $artistName";

  @override
  String getDescription() => albumName ?? path;

  @override
  String getSearchTerm() => "$title - $artistName";

  @override
  Map<String, dynamic> toJson() => {
    'path': path,
    'id': id,
    'title': title,
    'artistName': artistName,
    'albumName': albumName,
    'duration': duration.inMilliseconds,
    'thumbnailUrl': thumbnailUrl,
    'artistId': artistId,
    'albumId': albumId,
  };

  @override
  Map<String, dynamic> toMediaItem() => {
    'id': id,
    'title': title,
    'artist': artistName,
    'album': albumName,
    'duration': duration.inMilliseconds,
    'artUri': thumbnailUrl,
  };

  factory LocalTrack.fromJson(Map<String, dynamic> json) {
    return LocalTrack(
      path: json['path'],
      title: json['title'],
      artistName: json['artistName'],
      albumName: json['albumName'],
      duration: Duration(milliseconds: json['duration']),
      thumbnailUrl: json['thumbnailUrl'],
      id: json['id'],
      artistId: json['artistId'],
      albumId: json['albumId'],
    );
  }

  factory LocalTrack.fromFile(
    File file, {
    Metadata? metadata,
    String? art,
  }) {
    final name = metadata?.title ?? basenameWithoutExtension(file.path);
    return LocalTrack(
      path: file.path,
      title: name,
      artistName: metadata?.artist ?? "Unknown",
      albumName: metadata?.album,
      duration: Duration(milliseconds: metadata?.durationMs?.toInt() ?? 0),
      thumbnailUrl: art,
      artistId: metadata?.artist,
      albumId: metadata?.album,
    );
  }

  Metadata toMetadata({
    required int fileLength,
    Uint8List? imageBytes,
  }) {
    return Metadata(
      title: title,
      artist: artistName,
      album: albumName,
      albumArtist: artistName,
      year: 1969,
      durationMs: duration.inMilliseconds.toDouble(),
      fileSize: BigInt.from(fileLength),
      picture: imageBytes != null
          ? Picture(
              data: imageBytes,
              mimeType: 'image/jpeg',
            )
          : null,
    );
  }
}