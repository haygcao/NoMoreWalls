import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';

import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/album.dart'; // Add this import

class ArtistAlbumList extends HookConsumerWidget {
  final String artistId;
  final List<AlbumBase> albums;
  final bool isLoadingNextPage;
  final bool hasNextPage;
  final Future<void> Function()? onFetchMore;

  const ArtistAlbumList({
    required this.artistId,
    required this.albums,
    this.isLoadingNextPage = false,
    this.hasNextPage = false,
    this.onFetchMore,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);

    // Convert AlbumBase to Album
    final albumsList = albums.map((album) {
      if (album is Album) return album;
      // Create a placeholder Album if it's not already an Album
      return Album(
        id: album.id,
        name: album.name,
        uri: '', // Provide a default URI
        imageUrl: album.imageUrl,
        artists: album.artists,
        releaseDate: album.releaseDate,
        albumType: album.albumType,
        tracks: album.tracks,
      );
    }).toList();

    return HorizontalPlaybuttonCardView<Album>(
      isLoadingNextPage: isLoadingNextPage,
      hasNextPage: hasNextPage,
      items: albumsList,
      onFetchMore: onFetchMore != null ? () {
        // Ignore the future, just call the function
        onFetchMore!();
      } : () {},
      title: Text(
        context.l10n.albums,
        style: theme.textTheme.headlineSmall,
      ),
    );
  }
}
