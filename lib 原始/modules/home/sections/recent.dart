import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/fake.dart';
import 'package:spotube/components/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/history/recent.dart';
import 'package:spotube/provider/music_platform.dart';

class HomeRecentlyPlayedSection extends HookConsumerWidget {
  const HomeRecentlyPlayedSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // 获取当前音乐平台
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    
    // 获取历史记录
    final history = ref.watch(recentlyPlayedItems);
    final historyData =
        history.asData?.value ?? FakeData.historyRecentlyPlayedItems;

    // 如果没有历史记录，不显示任何内容
    if (history.asData?.value.isEmpty == true) {
      return const SizedBox();
    }

    // 根据当前平台过滤历史记录
    final filteredHistory = currentPlatform == MusicPlatform.mixed
        ? historyData // 混合模式显示所有内容
        : historyData.where((item) {
            // 检查播放列表或专辑的来源
            String? source;
            
            // 使用条件访问操作符 ?. 安全地访问 source 属性
            if (item.playlist != null) {
              // 从 data 字段中获取 source 信息
              source = item.data['source'] as String?;
            } else if (item.album != null) {
              // 从 data 字段中获取 source 信息
              source = item.data['source'] as String?;
            }
            
            // 根据当前平台过滤
            if (currentPlatform == MusicPlatform.spotify) {
              return source == 'spotify' || source == null;
            } else if (currentPlatform == MusicPlatform.youtubeMusic) {
              return source == 'youtube' || source == 'youtube_music';
            }
            return true;
          }).toList();

    // 如果过滤后没有内容，不显示任何内容
    if (filteredHistory.isEmpty) {
      return const SizedBox();
    }

    return Skeletonizer(
      enabled: history.isLoading,
      child: HorizontalPlaybuttonCardView(
        title: Text(context.l10n.recently_played),
        items: [
          for (final item in filteredHistory)
            if (item.playlist != null)
              item.playlist!
            else if (item.album != null)
              item.album!
        ],
        hasNextPage: false,
        isLoadingNextPage: false,
        onFetchMore: () {},
      ),
    );
  }
}
