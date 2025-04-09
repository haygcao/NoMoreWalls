
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/modules/player/player_queue.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';

class PlayerQueuePage extends HookConsumerWidget {
  const PlayerQueuePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final playlist = ref.watch(audioPlayerProvider);
    final playlistNotifier = ref.read(audioPlayerProvider.notifier);
    final selectedTracks = useState<Set<int>>({});
    final isSelectionMode = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.queue),
        actions: [
          if (isSelectionMode.value)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: context.l10n.cancel,
              onPressed: () {
                isSelectionMode.value = false;
                selectedTracks.value = {};
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: context.l10n.clear_queue,
              onPressed: () {
                playlistNotifier.clearQueue();
              },
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            PlayerQueue.fromAudioPlayerNotifier(
              floating: false,
              playlist: playlist,
              notifier: playlistNotifier,
              onTrackTap: (track, index) {
                if (isSelectionMode.value) {
                  final newSelection = Set<int>.from(selectedTracks.value);
                  if (newSelection.contains(index)) {
                    newSelection.remove(index);
                  } else {
                    newSelection.add(index);
                  }
                  selectedTracks.value = newSelection;
                  return;
                }
                
                // 正常播放逻辑
                if (playlist.activeTrack?.id != track.id) {
                  playlistNotifier.jumpToTrack(track);
                }
              },
              onTrackLongPress: (track, index) {
                if (!isSelectionMode.value) {
                  isSelectionMode.value = true;
                  selectedTracks.value = {index};
                }
              },
              selectedIndices: isSelectionMode.value ? selectedTracks.value : null,
            ),
            
            // 底部的移除按钮
            if (isSelectionMode.value && selectedTracks.value.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      // 移除选中的歌曲
                      final indices = selectedTracks.value.toList()..sort();
                      for (int i = indices.length - 1; i >= 0; i--) {
                        final trackId = playlist.tracks[indices[i]].id;
                        playlistNotifier.removeTrack(trackId);
                      }
                      isSelectionMode.value = false;
                      selectedTracks.value = {};
                    },
                    child: Text(context.l10n.remove),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}