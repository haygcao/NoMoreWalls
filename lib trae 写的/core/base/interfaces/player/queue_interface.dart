import '../media/track_interface.dart';

/// Interface defining the queue management functionality
abstract class QueueInterface {
  /// List of tracks in the queue
  List<TrackInterface> get tracks;

  /// Current track index in the queue
  int get currentIndex;

  /// Total number of tracks in queue
  int get length;

  /// Whether the queue is empty
  bool get isEmpty;

  /// Original unshuffled queue
  List<TrackInterface> get originalQueue;

  /// Add tracks to the end of queue
  Future<void> add(List<TrackInterface> tracks);

  /// Add tracks next in queue (after current track)
  Future<void> addNext(List<TrackInterface> tracks);

  /// Remove tracks from queue
  Future<void> remove(List<TrackInterface> tracks);

  /// Clear the entire queue
  Future<void> clear();

  /// Move track from one position to another
  Future<void> move(int oldIndex, int newIndex);

  /// Skip to specific track in queue
  Future<void> skipTo(int index);

  /// Shuffle the queue
  Future<void> shuffle();

  /// Restore original queue order
  Future<void> unshuffle();

  /// Get the next track in queue
  TrackInterface? getNextTrack();

  /// Get the previous track in queue
  TrackInterface? getPreviousTrack();

  /// Stream of queue changes
  Stream<List<TrackInterface>> get onQueueChanged;

  /// Stream of current track index changes
  Stream<int> get onCurrentIndexChanged;
}
