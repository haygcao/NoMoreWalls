import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/titlebar/titlebar.dart';
import 'package:spotube/components/image/universal_image.dart';

import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';

import 'package:spotube/hooks/utils/use_custom_status_bar_color.dart';
import 'package:spotube/hooks/utils/use_palette_color.dart';
import 'package:spotube/pages/lyrics/plain_lyrics.dart';
import 'package:spotube/pages/lyrics/synced_lyrics.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
// 移除 spotify 导入
import 'package:spotube/provider/lyrics/lyrics_providers.dart';

import 'package:spotube/utils/platform.dart';
import 'package:spotube/utils/type/image_type.dart';


class LyricsPage extends HookConsumerWidget {
  static const name = "lyrics";

  final bool isModal;
  const LyricsPage({super.key, this.isModal = false});

  @override
  Widget build(BuildContext context, ref) {
    final playlist = ref.watch(audioPlayerProvider);
    final activeTrack = playlist.activeTrack;
    String albumArt = useMemoized(
      () {
        final url = activeTrack?.thumbnailUrl;
        return url ?? ImagePlaceholder.albumArt.toString();
      },
      [activeTrack?.thumbnailUrl],
    );

    final palette = usePaletteColor(albumArt, ref);
    final mediaQuery = MediaQuery.of(context);
    final route = ModalRoute.of(context);

    final resetStatusBar = useCustomStatusBarColor(
      palette.color,
      route?.isCurrent ?? false,
      noSetBGColor: true,
    );

    PreferredSizeWidget tabbar = TabBar(
      tabs: [
        Tab(text: "  ${context.l10n.synced}  "),
        Tab(text: "  ${context.l10n.plain}  "),
      ],
      // 添加一些样式使其更美观
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
    );

    tabbar = PreferredSize(
      preferredSize: tabbar.preferredSize,
      child: Row(
        children: [
          tabbar,
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final track = ref.watch(activeTrackProvider);
              final lyric = ref.watch(lyricsProvider(track));
              final providerName = lyric.asData?.value.provider;

              if (providerName == null) {
                return const SizedBox.shrink();
              }

              return Align(
                alignment: Alignment.bottomRight,
                child: Text(context.l10n.powered_by_provider(providerName)),
              );
            },
          ),
          const Gap(5),
        ],
      ),
    );

    if (isModal) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (_, __) => resetStatusBar(),
        child: DefaultTabController(
          length: 2,
          child: SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Container(
                      height: 7,
                      width: 150,
                      decoration: BoxDecoration(
                        color: palette.titleTextColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    TitleBar(
                      leading: const [BackButton()],
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      trailing: [
                        IconButton(
                          icon: const Icon(SpotubeIcons.minimize),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SyncedLyrics(palette: palette, isModal: isModal),
                          PlainLyrics(palette: palette, isModal: isModal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: mediaQuery.mdAndUp,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: !kIsMacOS
              ? TitleBar(
                  backgroundColor: Colors.transparent,
                  title: tabbar,
                )
              : tabbar,
          body: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: UniversalImage.imageProvider(albumArt),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
              ),
            ),
            margin: const EdgeInsets.only(bottom: 10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ColoredBox(
                color: palette.color.withOpacity(.7),
                child: SafeArea(
                  child: TabBarView(
                    children: [
                      SyncedLyrics(palette: palette, isModal: isModal),
                      PlainLyrics(palette: palette, isModal: isModal),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
