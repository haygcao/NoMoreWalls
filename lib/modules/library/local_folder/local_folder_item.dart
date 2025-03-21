import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
// 保留 go_router 导入，因为我们需要使用 queryParameters

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/hooks/utils/use_brightness_value.dart';
// 移除页面导入
// import 'package:spotube/pages/library/local_folder.dart';
import 'package:spotube/provider/local_tracks/local_tracks_provider.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/modules/library/local_folder/components/folder_grid_view.dart';
import 'package:spotube/modules/library/local_folder/components/folder_title_bar.dart';
import 'package:spotube/modules/library/local_folder/components/folder_path_view.dart';
// 添加 NavigationService 导入
import 'package:spotube/services/navigation/navigation_service.dart';

class LocalFolderItem extends HookConsumerWidget {
  final String folder;
  const LocalFolderItem({super.key, required this.folder});

  @override
  Widget build(BuildContext context, ref) {
    // 获取导航服务
    final navigationService = ref.watch(navigationServiceProvider);
    
    final ThemeData(:colorScheme) = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final lerpValue = useBrightnessValue(.9, .7);

    final downloadFolder =
        ref.watch(userPreferencesProvider.select((s) => s.downloadLocation));
    final cacheFolder = useFuture(UserPreferencesNotifier.getMusicCacheDir());

    final isDownloadFolder = folder == downloadFolder;
    final isCacheFolder = folder == cacheFolder.data;

    final Uri(:pathSegments) = Uri.parse(
      folder
          .replaceFirst(RegExp(r'^/Volumes/[^/]+/Users/'), "")
          .replaceFirst(r'C:\Users\', "")
          .replaceFirst(r'/home/', ""),
    );

    // if length > 5, we ... all the middle segments after 2 and the last 2
    final segments = pathSegments.length > 5
        ? [
            ...pathSegments.take(2),
            "...",
            ...pathSegments.skip(pathSegments.length - 3).toList()
              ..removeLast(),
          ]
        : pathSegments.take(max(pathSegments.length - 1, 0)).toList();

    final trackSnapshot = ref.watch(
      localTracksProvider.select(
        (s) => s.whenData((tracks) => tracks[folder]?.take(4).toList()),
      ),
    );

    final tracks = trackSnapshot.value ?? [];

    return InkWell(
      onTap: () {
        // 使用 NavigationService 导航
        navigationService.router.pushNamed(
          "local-library", // 使用路由名称而不是页面类名
          queryParameters: {
            if (isDownloadFolder) "downloads": "true",
            if (isCacheFolder) "cache": "true",
          },
          extra: folder,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color.lerp(
            colorScheme.surfaceContainerHighest,
            colorScheme.surface,
            lerpValue,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FolderGridView(
                tracks: tracks,
                mediaQuery: mediaQuery,
              ),
              const Gap(8),
              FolderTitleBar(
                folder: folder,
                isDownloadFolder: isDownloadFolder,
                isCacheFolder: isCacheFolder,
              ),
              const Spacer(),
              FolderPathView(segments: segments),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
