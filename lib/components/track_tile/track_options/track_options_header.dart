import 'package:flutter/material.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/utils/type/image_type.dart';

class TrackOptionsHeader extends StatelessWidget {
  final SourceableTrack track;
  final void Function(String id)? onTrackTap;
  final void Function(String id)? onArtistTap;

  const TrackOptionsHeader({
    super.key,
    required this.track,
    this.onTrackTap,
    this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: UniversalImage(
            path: track.thumbnailUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: track.artistId != null && onArtistTap != null 
              ? () => onArtistTap!(track.artistId!) 
              : null,
          child: Text(
            track.artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: track.artistId != null && onArtistTap != null
                  ? TextDecoration.underline
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}