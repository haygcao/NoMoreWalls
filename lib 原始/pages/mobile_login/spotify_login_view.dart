import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/music_platform.dart';


class SpotifyLoginView extends HookConsumerWidget {
  const SpotifyLoginView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final authenticationNotifier = ref.watch(authenticationProvider.notifier);

    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      ),
      initialUrlRequest: URLRequest(
        url: WebUri("https://accounts.spotify.com/"),
      ),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onLoadStop: (controller, action) async {
        if (action == null) return;
        String url = action.toString();
        if (url.endsWith("/")) {
          url = url.substring(0, url.length - 1);
        }

        final exp = RegExp(r"https:\/\/accounts.spotify.com\/.+\/status");
        if (exp.hasMatch(url)) {
          final cookies = await CookieManager.instance().getCookies(url: action);
          final cookieHeader = "sp_dc=${cookies.firstWhere((element) => element.name == "sp_dc").value}";

          // 修改这一行，传入 MusicPlatform.spotify 和包含 cookie 的 Map
          await authenticationNotifier.login(
            MusicPlatform.spotify, 
            {'cookie': cookieHeader}
          );
          
          if (context.mounted) {
            context.go("/");
          }
        }
      },
    );
  }
}