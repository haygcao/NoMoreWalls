import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/provider/spotify/spotify.dart';

// 导入通用模型和工具类
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/utils/type/image_type.dart';

import 'package:url_launcher/url_launcher_string.dart';

class ArtistPageFooter extends ConsumerWidget {
  // 使用通用 Artist 类型
  final Artist artist;
  const ArtistPageFooter({super.key, required this.artist});

  @override
  Widget build(BuildContext context, ref) {
    final ThemeData(:textTheme) = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // 使用 MediaImageUtils 获取图片 URL
    final artistImage = artist.imageUrl ?? 
        MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.artist);
    
    // 创建一个临时的 Spotify ArtistSimple 对象来使用 Wikipedia 提供者
    final spotifyArtist = spotify.Artist()..name = artist.name;
    
    // 使用 Spotify 的 Wikipedia 提供者
    final summary = ref.watch(artistWikipediaSummaryProvider(spotifyArtist));
    if (summary.asData?.value == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: mediaQuery.smAndDown
          ? const EdgeInsets.all(20)
          : const EdgeInsets.all(30),
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
          image: UniversalImage.imageProvider(
            summary.asData?.value!.thumbnail?.source_ ?? artistImage,
            height: summary.asData?.value!.thumbnail?.height.toDouble(),
            width: summary.asData?.value!.thumbnail?.width.toDouble(),
          ),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
          children: [
            // icon
            const WidgetSpan(
              child: Icon(
                SpotubeIcons.wikipedia,
                color: Colors.white,
                size: 30,
              ),
            ),
            TextSpan(
              text: " Wikipedia",
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const TextSpan(text: '\n\n'),
            TextSpan(
              text: summary.asData?.value!.extract,
            ),
            TextSpan(
              text: '\n...read more at wikipedia',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.lightBlue[300],
                decoration: TextDecoration.underline,
                decorationColor: Colors.lightBlue[300],
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await launchUrlString(
                    "http://en.wikipedia.org/wiki?curid=${summary.asData?.value?.pageid}",
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
