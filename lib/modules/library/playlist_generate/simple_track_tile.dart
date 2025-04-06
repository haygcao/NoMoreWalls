import 'package:flutter/material.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/utils/type/image_type.dart';

class SimpleTrackTile extends StatelessWidget {
  final SourceableTrack track;
  // 添加 onRemove 回调函数
  final VoidCallback? onRemove;

  const SimpleTrackTile({
    super.key,
    required this.track,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 40,
            width: 40,
            child: UniversalImage(
              path: track.thumbnailUrl ?? 
                  MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
              height: 40,
              width: 40,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                track.artistName,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // 添加删除按钮
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onRemove,
            splashRadius: 20,
          ),
      ],
    );
  }
}
