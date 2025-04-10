import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/modules/playlist/playlist_create_dialog.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/playlist/playlist_provider.dart';

import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/utils/type/image_type.dart';

class PlaylistAddTrackDialog extends HookConsumerWidget {
  /// The id of the playlist this dialog was opened from
  final String? openFromPlaylist;
  final List<SourceableTrack> tracks;
  const PlaylistAddTrackDialog({
    required this.tracks,
    required this.openFromPlaylist,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final ThemeData(:textTheme) = Theme.of(context);
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    final userPlaylists = ref.watch(currentPlatformPlaylistsProvider);
    final unifiedPlaylistNotifier = ref.watch(unifiedPlaylistProvider.notifier);

    final filteredPlaylists = useMemoized(
      () =>
          userPlaylists.asData?.value
              .where(
                (playlist) => playlist.id != openFromPlaylist,
              )
              .toList() ??
          [],
      [userPlaylists.asData?.value, openFromPlaylist],
    );

    final playlistsCheck = useState(<String, bool>{});

    useEffect(() {
      if (userPlaylists.asData?.value != null) {
        unifiedPlaylistNotifier.fetchPlaylists(currentPlatform);
      }
      return null;
    }, [userPlaylists.asData?.value]);

    Future<void> onAdd() async {
      final selectedPlaylists = playlistsCheck.value.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key);

      await Future.wait(
        selectedPlaylists.map(
          (playlistId) => unifiedPlaylistNotifier.addTracks(
            currentPlatform,
            playlistId,
            tracks.map((e) => e.id).toList(),
          ),
        ),
      ).then((_) => Navigator.pop(context, true));
    }

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.add_to_playlist,
            style: textTheme.titleMedium,
          ),
          const Gap(20),
          const PlaylistCreateDialogButton(),
        ],
      ),
      actions: [
        OutlinedButton(
          child: Text(context.l10n.cancel),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FilledButton(
          onPressed: onAdd,
          child: Text(context.l10n.add),
        ),
      ],
      content: SizedBox(
        height: 300,
        width: 300,
        child: userPlaylists.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                itemCount: filteredPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = filteredPlaylists.elementAt(index);
                  return CheckboxListTile(
                    secondary: CircleAvatar(
                      backgroundImage: UniversalImage.imageProvider(
                        playlist.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.collection),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(playlist.name),
                    ),
                    value: playlistsCheck.value[playlist.id] ?? false,
                    onChanged: (val) {
                      playlistsCheck.value = {
                        ...playlistsCheck.value,
                        playlist.id: val == true
                      };
                    },
                  );
                },
              ),
      ),
    );
  }
}
