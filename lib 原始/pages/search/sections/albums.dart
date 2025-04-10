import 'package:flutter/material.dart' hide Page;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
// 移除 Spotify 特定扩展
// import 'package:spotube/provider/spotify/extension/album_simple.dart';
import 'package:spotube/extensions/context.dart';
// 替换为统一搜索提供者
import 'package:spotube/provider/search/unified_search_provider.dart';
// 添加通用专辑模型
import 'package:spotube/services/base/album.dart';

class SearchAlbumsSection extends HookConsumerWidget {
  const SearchAlbumsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 使用统一搜索提供者
    final query = ref.watch(unifiedSearchProvider(SearchType.album));
    final notifier = ref.watch(unifiedSearchProvider(SearchType.album).notifier);
    // 直接使用通用 Album 类型，不需要转换
    final albums = useMemoized(
      () => query.asData?.value.items.cast<Album>().toList() ?? [],
      [query.asData?.value],
    );

    return HorizontalPlaybuttonCardView(
      isLoadingNextPage: query.isRefreshing,
      hasNextPage: query.asData?.value.hasMore == true,
      items: albums,
      onFetchMore: notifier.fetchMore,
      title: Text(context.l10n.albums),
    );
  }
}
