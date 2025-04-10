part of '../service_utils.dart';

extension MediaUtils on ServiceUtils {
  static DateTime parseAlbumDate(
    String? releaseDate, 
    String? precision,
  ) {
    if (releaseDate == null) {
      return DateTime.parse("1975-01-01");
    }

    switch (precision ?? 'year') {
      case 'day':
        return DateTime.parse(releaseDate);
      case 'month':
        return DateTime.parse("$releaseDate-01");
      case 'year':
        return DateTime.parse("$releaseDate-01-01");
      default:
        return DateTime.parse("1975-01-01");
    }
  }

  static List<T> sortMediaItems<T extends MediaBase>(
    List<T> items,
    SortBy sortBy,
  ) {
    if (sortBy == SortBy.none) return items;
    return List<T>.from(items)
      ..sort((a, b) {
        switch (sortBy) {
          case SortBy.ascending:
            return a.name.compareTo(b.name);
          case SortBy.descending:
            return b.name.compareTo(a.name);
          case SortBy.newest:
            final aDate = parseAlbumDate(a.releaseDate, a.releaseDatePrecision);
            final bDate = parseAlbumDate(b.releaseDate, b.releaseDatePrecision);
            return bDate.compareTo(aDate);
          case SortBy.oldest:
            final aDate = parseAlbumDate(a.releaseDate, a.releaseDatePrecision);
            final bDate = parseAlbumDate(b.releaseDate, b.releaseDatePrecision);
            return aDate.compareTo(bDate);
          case SortBy.duration:
            return (a.durationMs ?? 0).compareTo(b.durationMs ?? 0);
          case SortBy.artist:
            return (a.artistName ?? "").compareTo(b.artistName ?? "");
          case SortBy.album:
            return (a.albumName ?? "").compareTo(b.albumName ?? "");
          default:
            return 0;
        }
      });
  }

static List<T> sortTracks<T extends BaseTrack>(List<T> tracks, SortBy sortBy) {
    if (sortBy == SortBy.none) return tracks;
    return List<T>.from(tracks)
      ..sort((a, b) {
        switch (sortBy) {
          case SortBy.ascending:
            return a.title.compareTo(b.title);
          case SortBy.descending:
            return b.title.compareTo(a.title);
          case SortBy.newest:
            // 检查是否有 releaseDate 属性
            final aDate = a is ExtendedBaseTrack ? a.releaseDate : null;
            final bDate = b is ExtendedBaseTrack ? b.releaseDate : null;
            return (bDate ?? DateTime(1970)).compareTo(aDate ?? DateTime(1970));
          case SortBy.oldest:
            // 检查是否有 releaseDate 属性
            final aDate = a is ExtendedBaseTrack ? a.releaseDate : null;
            final bDate = b is ExtendedBaseTrack ? b.releaseDate : null;
            return (aDate ?? DateTime(1970)).compareTo(bDate ?? DateTime(1970));
          case SortBy.duration:
            return (a.duration ?? Duration.zero)
                .compareTo(b.duration ?? Duration.zero);
          case SortBy.artist:
            return (a.artistName ?? '')
                .compareTo(b.artistName ?? '');
          case SortBy.album:
            return (a.albumName ?? '')
                .compareTo(b.albumName ?? '');
          default:
            return 0;
        }
      });
  }



  static Future<Uint8List?> downloadImage(String imageUrl) async {
    try {
      final fileStream = DefaultCacheManager().getImageFile(imageUrl);
      final bytes = List<int>.empty(growable: true);
      await for (final data in fileStream) {
        if (data is FileInfo) {
          bytes.addAll(data.file.readAsBytesSync());
          break;
        }
      }
      return Uint8List.fromList(bytes);
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace);
      return null;
    }
  }
}