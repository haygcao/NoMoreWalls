import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/formatters.dart';
import 'package:spotube/modules/stats/common/album_item.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/history/top.dart';
import 'package:spotube/provider/history/top/albums.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
// Add import for Album class
import 'package:spotube/services/base/album.dart';

class TopAlbums extends HookConsumerWidget {
  const TopAlbums({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final historyDuration = ref.watch(playbackHistoryTopDurationProvider);
    final topAlbums = ref.watch(historyTopAlbumsProvider(historyDuration));
    final topAlbumsNotifier =
        ref.watch(historyTopAlbumsProvider(historyDuration).notifier);

    final albumsData = topAlbums.asData?.value.items ?? [];

    return Skeletonizer.sliver(
      enabled: topAlbums.isLoading && !topAlbums.isLoadingNextPage,
      child: SliverInfiniteList(
        onFetchData: () async {
          await topAlbumsNotifier.fetchMore();
        },
        hasError: topAlbums.hasError,
        isLoading: topAlbums.isLoading && !topAlbums.isLoadingNextPage,
        hasReachedMax: topAlbums.asData?.value.hasMore ?? true,
        itemCount: albumsData.length,
        itemBuilder: (context, index) {
          final album = albumsData[index];
          // Convert AlbumBase to Album
          final albumObj = _convertToAlbum(album.album);
          return StatsAlbumItem(
            album: albumObj,
            info: Text(
              context.l10n
                  .count_plays(compactNumberFormatter.format(album.count)),
            ),
          );
        },
      ),
    );
  }
  
  // Helper method to convert AlbumBase to Album
  Album _convertToAlbum(AlbumBase albumBase) {
    return Album(
      id: albumBase.id,
      name: albumBase.name,
      uri: '', // You might need to provide a default or get this from somewhere
      imageUrl: albumBase.imageUrl,
      artists: albumBase.artists,
      releaseDate: albumBase.releaseDate,
      albumType: albumBase.albumType,
      tracks: albumBase.tracks,
    );
  }
}
