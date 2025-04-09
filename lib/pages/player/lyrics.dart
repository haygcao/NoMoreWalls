import 'package:auto_route/annotations.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/button/back_button.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/hooks/utils/use_palette_color.dart';
import 'package:spotube/pages/lyrics/plain_lyrics.dart';
import 'package:spotube/pages/lyrics/synced_lyrics.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
// 移除未使用的导入
// import 'package:spotube/provider/lyrics/lyrics_providers.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/utils/type/image_type.dart';

@RoutePage()
class PlayerLyricsPage extends HookConsumerWidget {
  const PlayerLyricsPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final playlist = ref.watch(audioPlayerProvider);
    // 修改获取专辑封面的方式
    String albumArt = useMemoized(
      () {
        // 直接使用 thumbnailUrl 属性，而不是 album.imageUrl
        final imageUrl = playlist.activeTrack?.thumbnailUrl;
        return imageUrl ?? ImagePlaceholder.albumArt.toString();
      },
      [playlist.activeTrack?.thumbnailUrl],
    );
    final selectedIndex = useState(0);
    final palette = usePaletteColor(albumArt, ref);

    final tabbar = Padding(
        padding: const EdgeInsets.all(10),
        child: TabList(
          index: selectedIndex.value,
          onChanged: (index) => selectedIndex.value = index,
          children: [
            TabItem(
              child: Text(context.l10n.synced),
            ),
            TabItem(
              child: Text(context.l10n.plain),
            ),
          ],
        ));

    return Scaffold(
      headers: [
        AppBar(
          leading: [tabbar],
          trailing: const [
            BackButton(icon: SpotubeIcons.angleDown),
          ],
        ),
      ],
      child: IndexedStack(
        index: selectedIndex.value,
        children: [
          SyncedLyrics(palette: palette, isModal: false),
          PlainLyrics(palette: palette, isModal: false),
        ],
      ),
    );
  }
}