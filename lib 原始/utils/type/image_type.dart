import 'package:spotube/collections/assets.gen.dart';
import 'package:spotube/utils/primitive_utils.dart';

enum ImagePlaceholder {
  albumArt,
  artist,
  collection,
  online,
}

abstract class MediaImage {
  String? get url;
  int? get width;
  int? get height;
}

class MediaImageUtils {
  static String getPlaceholderUrl(ImagePlaceholder type) {
    return switch (type) {
      ImagePlaceholder.albumArt => Assets.albumPlaceholder.path,
      ImagePlaceholder.artist => Assets.userPlaceholder.path,
      ImagePlaceholder.collection => Assets.placeholder.path,
      ImagePlaceholder.online => "https://avatars.dicebear.com/api/bottts/${PrimitiveUtils.uuid.v4()}.png",
    };
  }

  static String getImageUrl(List<MediaImage>? images, {
    int index = 1,
    required ImagePlaceholder placeholder,
  }) {
    if (images == null || images.isEmpty) {
      return getPlaceholderUrl(placeholder);
    }

    final sortedImages = List<MediaImage>.from(images)
      ..sort((a, b) => (a.width ?? 0).compareTo(b.width ?? 0));

    final actualIndex = index > sortedImages.length - 1 
        ? sortedImages.length - 1 
        : index;
        
    return sortedImages[actualIndex].url ?? getPlaceholderUrl(placeholder);
  }
}