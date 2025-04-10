import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/local_track.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/sourced_track.dart';

class SourcedTrackNotifier
    extends FamilyAsyncNotifier<SourcedTrack?, SpotubeMedia?> {
  @override
  build(media) async {
    final track = media?.track;
    // 保留 LocalTrack 检查，同时确保 track 实现了 SourceableTrack
    if (track == null || track is LocalTrack) {
      return null;
    }

    ref.listen(
      audioPlayerProvider.select((value) => value.tracks),
      (old, next) {
        if (next.isEmpty || next.none((element) => element.id == track.id)) {
          ref.invalidateSelf();
        }
      },
    );

    // 确保 track 是 SourceableTrack 类型
    final sourcedTrack =
        await SourcedTrack.fetchFromTrack(track: track);

    return sourcedTrack;
  }

  Future<SourcedTrack?> switchToAlternativeSources() async {
    if (arg == null) {
      return null;
    }
    return await update((prev) async {
      // 确保 track 是 SourceableTrack 类型
      return await SourcedTrack.fetchFromTrackAltSource(
        track: arg!.track,
        
      );
    });
  }
}

final sourcedTrackProvider = AsyncNotifierProviderFamily<SourcedTrackNotifier,
    SourcedTrack?, SpotubeMedia?>(
  () => SourcedTrackNotifier(),
);
