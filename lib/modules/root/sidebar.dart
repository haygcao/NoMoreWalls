import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import 'package:spotube/collections/assets.gen.dart';
import 'package:spotube/collections/side_bar_tiles.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/modules/connect/connect_device.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';

import 'package:spotube/hooks/utils/use_brightness_value.dart';
import 'package:spotube/hooks/controllers/use_sidebarx_controller.dart';

import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/download_manager_provider.dart';
import 'package:spotube/provider/music_platform.dart';

import 'package:spotube/provider/user/user_provider.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/utils/platform.dart';
// 移除 ServiceUtils 导入
// import 'package:spotube/utils/service_utils.dart';
// 添加 NavigationService 导入
import 'package:spotube/services/navigation/navigation_service.dart';
import 'package:window_manager/window_manager.dart';

class Sidebar extends HookConsumerWidget {
  final Widget child;

  const Sidebar({
    required this.child,
    super.key,
  });

  static Widget brandLogo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Assets.spotubeLogoPng.image(height: 50),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = GoRouterState.of(context);
    final mediaQuery = MediaQuery.of(context);

    final downloadCount = ref.watch(downloadManagerProvider).$downloadCount;

    final layoutMode =
        ref.watch(userPreferencesProvider.select((s) => s.layoutMode));

    final sidebarTileList = useMemoized(
      () => getSidebarTileList(context.l10n),
      [context.l10n],
    );

    final selectedIndex = sidebarTileList.indexWhere(
      (e) => routerState.namedLocation(e.name) == routerState.matchedLocation,
    );

    final controller = useSidebarXController(
      selectedIndex: selectedIndex,
      extended: mediaQuery.lgAndUp,
    );

    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest;

    final bgColor = useBrightnessValue(
      Color.lerp(bg, Colors.white, 0.6),
      Color.lerp(bg, Colors.black, 0.45)!,
    );

    useEffect(() {
      if (!context.mounted) return;
      if (mediaQuery.lgAndUp && !controller.extended) {
        controller.setExtended(true);
      } else if (mediaQuery.mdAndDown && controller.extended) {
        controller.setExtended(false);
      }
      return null;
    }, [mediaQuery, controller]);

    useEffect(() {
      if (controller.selectedIndex != selectedIndex) {
        controller.selectIndex(selectedIndex);
      }
      return null;
    }, [selectedIndex]);

    if (layoutMode == LayoutMode.compact ||
        (mediaQuery.smAndDown && layoutMode == LayoutMode.adaptive)) {
      return Scaffold(body: child);
    }
    // 获取导航服务
    final navigationService = ref.watch(navigationServiceProvider);
    
    return Row(
      children: [
        SafeArea(
          child: SidebarX(
            controller: controller,
            items: sidebarTileList.mapIndexed(
              (index, e) {
                return SidebarXItem(
                  onTap: () {
                    context.goNamed(e.name);
                  },
                  iconBuilder: (selected, hovered) {
                    return Badge(
                      backgroundColor: theme.colorScheme.primary,
                      isLabelVisible: e.title == "Library" && downloadCount > 0,
                      label: Text(
                        downloadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      child: Icon(
                        e.icon,
                        color: selected || hovered
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    );
                  },
                  label: e.title,
                );
              },
            ).toList(),
            headerBuilder: (_, __) => const SidebarHeader(),
            footerBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: SidebarFooter(),
            ),
            showToggleButton: false,
            theme: SidebarXTheme(
              width: 50,
              margin: EdgeInsets.only(bottom: 10, top: kIsMacOS ? 35 : 5),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              selectedIconTheme: IconThemeData(
                color: theme.colorScheme.primary,
              ),
            ),
            extendedTheme: SidebarXTheme(
              width: 250,
              margin: EdgeInsets.only(
                bottom: 10,
                left: 0,
                top: kIsMacOS ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: bgColor?.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              selectedIconTheme: IconThemeData(
                color: theme.colorScheme.primary,
              ),
              selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              itemTextPadding: const EdgeInsets.only(left: 10),
              selectedItemTextPadding: const EdgeInsets.only(left: 10),
              hoverTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        Expanded(child: child)
      ],
    );
  }
}

class SidebarHeader extends HookWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    if (mediaQuery.mdAndDown) {
      return Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(bottom: 5),
        child: Sidebar.brandLogo(),
      );
    }

    return DragToMoveArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (kIsMacOS) const SizedBox(height: 25),
            Row(
              children: [
                Sidebar.brandLogo(),
                const SizedBox(width: 10),
                Text(
                  "Spotube",
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarFooter extends HookConsumerWidget {
  const SidebarFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    // 获取当前平台
    final currentPlatform = ref.watch(currentMusicPlatformProvider);
    // 使用通用用户提供者
    final currentUser = ref.watch(currentUserProvider);
    final userData = currentUser.asData?.value;

    // 使用通用图片工具获取头像
    final avatarImg = userData?.imageUrl ?? Assets.userPlaceholder.path;

    final auth = ref.watch(authenticationProvider);
    
    // 获取导航服务
    final navigationService = ref.watch(navigationServiceProvider);

    if (mediaQuery.mdAndDown) {
      return IconButton(
        icon: const Icon(SpotubeIcons.settings),
        // 修正：使用正确的导航方法
        onPressed: () => navigationService.navigateToSettings(),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 12),
      width: 250,
      child: Column(
        children: [
          const ConnectDeviceButton.sidebar(),
          const Gap(10),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 修正：根据当前平台检查认证状态
              if (auth[currentPlatform]?.asData?.value != null && userData == null)
                const CircularProgressIndicator()
              else if (userData != null)
                Flexible(
                  child: InkWell(
                    onTap: () {
                      // 修正：使用正确的导航方法
                      navigationService.navigateToProfile();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              UniversalImage.imageProvider(avatarImg),
                          onBackgroundImageError: (exception, stackTrace) =>
                              Assets.userPlaceholder.image(
                            height: 16,
                            width: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            userData.name ?? context.l10n.guest,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(SpotubeIcons.settings),
                onPressed: () {
                  // 修正：使用正确的导航方法
                  navigationService.navigateToSettings();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
