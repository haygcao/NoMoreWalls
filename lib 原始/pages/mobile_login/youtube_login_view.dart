import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/youtube_music/auth_provider.dart';

class YouTubeMusicLoginView extends HookConsumerWidget {
  const YouTubeMusicLoginView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final authNotifier = ref.watch(youtubeMusicAuthProvider.notifier);

    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      ),
      initialUrlRequest: URLRequest(
        url: WebUri("https://music.youtube.com"),
      ),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onLoadStop: (controller, action) async {
        if (action == null) return;
        final url = action.toString();
        
        if (url.contains('music.youtube.com')) {
          final cookies = await CookieManager.instance().getCookies(url: action);
          if (cookies.isNotEmpty) {
            final cookieMap = {
              for (var cookie in cookies)
                cookie.name: cookie.value
            };
            
            await authNotifier.login(Map<String, String>.from(cookieMap));
            if (context.mounted) {
              context.go("/");
            }
          }
        }
      },
    );
  }
}