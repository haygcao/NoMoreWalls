import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
// 替换为统一搜索提供者
import 'package:spotube/provider/search/unified_search_provider.dart';
// 添加通用艺术家模型
import 'package:spotube/services/base/artist.dart';

class SearchArtistsSection extends HookConsumerWidget {
  const SearchArtistsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    // 使用统一搜索提供者
    final query = ref.watch(unifiedSearchProvider(SearchType.artist));
    final notifier = ref.watch(unifiedSearchProvider(SearchType.artist).notifier);
    // 使用通用 Artist 类型
    final artists = query.asData?.value.items.cast<Artist>() ?? [];

    return HorizontalPlaybuttonCardView<Artist>(
      isLoadingNextPage: query.isRefreshing,
      hasNextPage: query.asData?.value.hasMore == true,
      items: artists,
      onFetchMore: notifier.fetchMore,
      title: Text(context.l10n.artists),
    );
  }
}
