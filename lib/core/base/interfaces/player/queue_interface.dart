import 'package:flutter/foundation.dart';

/// Interface for player queue functionality
///
/// Defines the methods and properties for managing the playback queue
@immutable
abstract class QueueInterface {
  /// Add a track to the queue
  Future<void> addTrack(String trackId);

  /// Add multiple tracks to the queue
  Future<void> addTracks(List<String> trackIds);

  /// Remove a track from the queue by its ID
  Future<void> removeTrack(String trackId);

  /// Remove a track from the queue by its position
  Future<void> removeTrackAt(int index);

  /// Clear the entire queue
  Future<void> clearQueue();

  /// Get all track IDs in the current queue
  Future<List<String>> getQueue();

  /// Get the current index in the queue
  Future<int> getCurrentIndex();

  /// Move a track in the queue from one position to another
  Future<void> moveTrack(int oldIndex, int newIndex);

  /// Skip to a specific track in the queue by index
  Future<void> skipToIndex(int index);

  /// Replace the entire queue with a new list of tracks
  Future<void> replaceQueue(List<String> trackIds, {int startIndex = 0});

  /// Get the history of played tracks
  Future<List<String>> getHistory();

  /// Clear the playback history
  Future<void> clearHistory();
}
