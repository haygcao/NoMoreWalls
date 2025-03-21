import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/provider/spotify/utils/sort_by.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class TrackViewNotifier extends ChangeNotifier {
  List<SourceableTrack> tracks;
  List<String> selectedTrackIds;
  SortBy sortBy;
  String? searchQuery;

  TrackViewNotifier(
    this.tracks, {
    this.selectedTrackIds = const [],
    this.sortBy = SortBy.none,
    this.searchQuery,
  });

  bool get isSelecting => selectedTrackIds.isNotEmpty;

  bool get hasSelectedAll =>
      selectedTrackIds.length == tracks.length && tracks.isNotEmpty;

  List<SourceableTrack> get selectedTracks =>
      tracks.where((e) => selectedTrackIds.contains(e.id)).toList();

  void selectTrack(String trackId) {
    selectedTrackIds = [...selectedTrackIds, trackId];
    notifyListeners();
  }

  void unselectTrack(String trackId) {
    selectedTrackIds = selectedTrackIds.where((e) => e != trackId).toList();
    notifyListeners();
  }

  void toggleTrackSelection(String trackId) {
    if (selectedTrackIds.contains(trackId)) {
      unselectTrack(trackId);
    } else {
      selectTrack(trackId);
    }
  }

  void selectAll() {
    selectedTrackIds = tracks.map((e) => e.id).toList();  // 移除 ! 因为 SourceableTrack 的 id 是非空的
    notifyListeners();
  }
  
  // 添加 deselectAll 方法
  void deselectAll() {
    selectedTrackIds = [];
    notifyListeners();
  }
  
  // 添加 sort 方法
  void sort(SortBy sortBy) {
    this.sortBy = sortBy;
    notifyListeners();
  }
}

final trackViewProvider = ChangeNotifierProvider.autoDispose
    .family<TrackViewNotifier, List<SourceableTrack>>((ref, tracks) {
  return TrackViewNotifier(tracks);
});
