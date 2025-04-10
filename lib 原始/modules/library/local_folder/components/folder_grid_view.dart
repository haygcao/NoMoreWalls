import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/utils/type/image_type.dart';

class FolderGridView extends StatelessWidget {
  final List<dynamic> tracks;
  final MediaQueryData mediaQuery;

  const FolderGridView({
    super.key,
    required this.tracks,
    required this.mediaQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            SpotubeIcons.folder,
            size: mediaQuery.smAndDown
                ? 95
                : mediaQuery.mdAndDown
                    ? 100
                    : 142,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max((tracks.length / 2).ceil(), 2),
        ),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return UniversalImage(
            path: MediaImageUtils.getImageUrl(
              track.album?.images,
              placeholder: ImagePlaceholder.albumArt,
            ),
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}