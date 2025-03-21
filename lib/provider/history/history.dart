import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/collection.dart';

class PlaybackHistoryActions {
  final Ref ref;
  AppDatabase get _db => ref.read(databaseProvider);

  PlaybackHistoryActions(this.ref);

  Future<void> _batchInsertHistoryEntries(
      List<HistoryTableCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAll(_db.historyTable, entries);
    });
  }

  Future<void> addCollection(Collection collection) async {
    await _db.into(_db.historyTable).insert(
          HistoryTableCompanion.insert(
            type: collection.type == CollectionType.album.name  // 使用枚举
                ? HistoryEntryType.album 
                : HistoryEntryType.playlist,
            itemId: collection.id,
            data: collection.toJson(),
          ),
        );
  }

  Future<void> addCollections(List<Collection> collections) async {
    await _batchInsertHistoryEntries([
      for (final collection in collections)
        HistoryTableCompanion.insert(
          type: collection.type == CollectionType.album.name  // 使用枚举
              ? HistoryEntryType.album 
              : HistoryEntryType.playlist,
          itemId: collection.id,
          data: collection.toJson(),
        ),
    ]);
  }
  
  // 添加专辑到历史记录
  Future<void> addAlbums(List<AlbumBase> albums) async {
    await addCollections(albums.map((album) => album as Collection).toList());
  }
  
  // 添加播放列表到历史记录
  Future<void> addPlaylists(List<PlaylistCollection> playlists) async {
    await addCollections(playlists.map((playlist) => playlist as Collection).toList());
  }

  Future<void> addTrack(SourceableTrack track) async {
    await _db.into(_db.historyTable).insert(
          HistoryTableCompanion.insert(
            type: HistoryEntryType.track,
            itemId: track.id,
            data: track.toJson(),
          ),
        );
  }

  Future<void> addTracks(List<SourceableTrack> tracks) async {
    await _batchInsertHistoryEntries([
      for (final track in tracks)
        HistoryTableCompanion.insert(
          type: HistoryEntryType.track,
          itemId: track.id,
          data: track.toJson(),
        ),
    ]);
  }

  Future<void> clear() async {
    _db.delete(_db.historyTable).go();
  }
}

final playbackHistoryActionsProvider =
    Provider((ref) => PlaybackHistoryActions(ref));
