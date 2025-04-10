import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
// 替换为统一搜索提供者
import 'package:spotube/provider/search/unified_search_provider.dart';
// 添加通用播放列表模型
import 'package:spotube/services/base/playlist.dart';

class SearchPlaylistsSection extends HookConsumerWidget {
  const SearchPlaylistsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 使用统一搜索提供者
    final playlistsQuery = ref.watch(unifiedSearchProvider(SearchType.playlist));
    final playlistsQueryNotifier =
        ref.watch(unifiedSearchProvider(SearchType.playlist).notifier);
    // 使用通用 Playlist 类型
    final playlists =
        playlistsQuery.asData?.value.items.cast<Playlist>() ?? [];

    return HorizontalPlaybuttonCardView(
      isLoadingNextPage: playlistsQuery.isRefreshing,
      hasNextPage: playlistsQuery.asData?.value.hasMore == true,
      items: playlists,
      onFetchMore: playlistsQueryNotifier.fetchMore,
      title: Text(context.l10n.playlists),
    );
  }
}
