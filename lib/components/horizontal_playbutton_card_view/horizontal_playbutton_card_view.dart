import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skeletonizer/skeletonizer.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/collections/fake.dart';
import 'package:spotube/modules/album/album_card.dart';
import 'package:spotube/modules/artist/artist_card.dart';
import 'package:spotube/modules/playlist/playlist_card.dart';
import 'package:spotube/hooks/utils/use_breakpoint_value.dart';
// 导入通用类型
import 'package:spotube/services/base/album.dart';
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/services/base/playlist.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class HorizontalPlaybuttonCardView<T> extends HookWidget {
  final Widget title;
  final List<T> items;
  final VoidCallback onFetchMore;
  final bool isLoadingNextPage;
  final bool hasNextPage;
  final Widget? titleTrailing;

  HorizontalPlaybuttonCardView({
    required this.title,
    required this.items,
    required this.hasNextPage,
    required this.onFetchMore,
    required this.isLoadingNextPage,
    this.titleTrailing,
    super.key,
  }) : assert(
          items.every(
            // 使用通用类型替换 Spotify 类型
            (item) => item is Playlist || item is Artist || item is Album,
          ),
        );

  @override
  Widget build(BuildContext context) {
    final ThemeData(:textTheme) = Theme.of(context);
    final scrollController = useScrollController();
    final height = useBreakpointValue<double>(
      xs: 226,
      sm: 226,
      md: 236,
      others: 266,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DefaultTextStyle(
                style: textTheme.titleMedium!,
                child: title,
              ),
              if (titleTrailing != null) titleTrailing!,
            ],
          ),
          SizedBox(
            height: height,
            child: NotificationListener(
              // disable multiple scrollbar to use this
              onNotification: (notification) => true,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: PointerDeviceKind.values.toSet(),
                ),
                child: items.isEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return AlbumCard(FakeData.album);
                        },
                      )
                    : InfiniteList(
                        scrollController: scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: items.length,
                        onFetchData: onFetchMore,
                        loadingBuilder: (context) => Skeletonizer(
                              enabled: true,
                              child: AlbumCard(FakeData.album),
                            ),
                        isLoading: isLoadingNextPage,
                        hasReachedMax: !hasNextPage,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return switch (item) {
                            Playlist() => PlaylistCard(item as Playlist),
                            Album() => AlbumCard(item as Album),
                            Artist() => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: ArtistCard(item as Artist),
                              ),
                            _ => const SizedBox.shrink(),
                          };
                        }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
