import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/services/cookie/cookie_manager.dart';
import 'package:spotube/provider/youtube_music/auth_provider.dart';
import 'package:spotube/provider/music_platform.dart'; // 添加这一行导入 MusicPlatform

import 'package:spotube/pages/mobile_login/mobile_login.dart';
import 'package:spotube/pages/mobile_login/no_webview_runtime_dialog.dart';

import 'package:spotube/utils/platform.dart';
enum LoginService {
  spotify,
  youtubeMusic
}

Future<void> Function() useLoginCallback(WidgetRef ref, LoginService service) {
  final context = useContext();
  final theme = Theme.of(context);
  final spotifyAuthNotifier = ref.read(authenticationProvider.notifier);
  final youtubeAuthNotifier = ref.read(youtubeMusicAuthProvider.notifier);
  final cookieManager = CookieManager();

  return useCallback(() async {
    if (kIsMobile || kIsMacOS) {
      context.pushNamed(WebViewLogin.name);
      return;
    }

    try {
      final config = _getServiceConfig(service);
      final applicationSupportDir = await getApplicationSupportDirectory();
      final userDataFolder = Directory(
          join(applicationSupportDir.path, "webview_window_Webview2"));

      if (!await userDataFolder.exists()) {
        await userDataFolder.create();
      }

      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          title: config.title,
          titleBarTopPadding: kIsMacOS ? 20 : 0,
          windowHeight: 720,
          windowWidth: 1280,
          userDataFolderWindows: userDataFolder.path,
        ),
      );

      webview
        ..setBrightness(theme.colorScheme.brightness)
        ..launch(config.url)
        ..setOnUrlRequestCallback((url) {
          if (config.urlPattern.hasMatch(url)) {
            webview.getAllCookies().then((cookies) async {
              final cookieMap = {
                for (var cookie in cookies)
                  cookie.name: cookie.value.replaceAll("\u0000", "")
              };

              // 保存 cookies 到统一管理器
              await cookieManager.saveCookies(
                service == LoginService.spotify ? 'spotify' : 'youtube_music',
                cookieMap
              );

              // 根据服务类型调用对应的登录处理
              if (service == LoginService.spotify) {
                final cookieHeader = "sp_dc=${cookieMap['sp_dc']}";
                // 修改这一行，传入 MusicPlatform.spotify 和包含 cookie 的 Map
                await spotifyAuthNotifier.login(
                  MusicPlatform.spotify, 
                  {'cookie': cookieHeader}
                );
              } else {
                // 对于 YouTube Music，也需要修改为使用新的 API
                await youtubeAuthNotifier.login(cookieMap);
              }

              webview.close();
              if (context.mounted) {
                context.go("/");
              }
            });
          }
          return true;
        });
    } on PlatformException catch (_) {
      if (!await WebviewWindow.isWebviewAvailable()) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showDialog(
            context: context,
            builder: (context) => const NoWebviewRuntimeDialog(),
          );
        });
      }
    }
  }, [service, cookieManager, spotifyAuthNotifier, youtubeAuthNotifier, theme, context.go]);
}

class _ServiceConfig {
  final String title;
  final String url;
  final RegExp urlPattern;

  const _ServiceConfig({
    required this.title,
    required this.url,
    required this.urlPattern,
  });
}

_ServiceConfig _getServiceConfig(LoginService service) {
  switch (service) {
    case LoginService.spotify:
      return _ServiceConfig(
        title: "Spotify Login",
        url: "https://accounts.spotify.com/",
        urlPattern: RegExp(r"https:\/\/accounts.spotify.com\/.+\/status"),
      );
    case LoginService.youtubeMusic:
      return _ServiceConfig(
        title: "YouTube Music Login",
        url: "https://music.youtube.com",
        urlPattern: RegExp(r"https:\/\/music\.youtube\.com"),
      );
  }
}
