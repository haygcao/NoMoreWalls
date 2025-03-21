
import 'package:spotube/services/base/sourceable_track.dart';

class TrackNotFoundError extends Error {
  final SourceableTrack track;
  TrackNotFoundError(this.track);
}
