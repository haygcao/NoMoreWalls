import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/services/navigation/navigation_service.dart';

class AnonymousFallback extends ConsumerWidget {
  final Widget? child;
  final MusicPlatform platform;
  
  const AnonymousFallback({
    super.key,
    this.child,
    this.platform = MusicPlatform.spotify, // 默认使用 Spotify 以保持向后兼容
  });

  @override
  Widget build(BuildContext context, ref) {
    final authState = ref.watch(authenticationProvider);
    final navigationService = ref.watch(navigationServiceProvider);
    
    // Get the specific platform's auth state
    final platformAuth = authState[platform];
    
    if (platformAuth?.isLoading == true) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if the user is authenticated for the specified platform
    if (platformAuth?.valueOrNull != null && child != null) return child!;
    
    // 根据平台获取登录按钮文本
    String loginButtonText;
    switch (platform) {
      case MusicPlatform.spotify:
        loginButtonText = context.l10n.login_with_spotify;
        break;
      case MusicPlatform.youtubeMusic:
        loginButtonText = "Login with YouTube Music";
        break;
      default:
        loginButtonText = "Login";
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.not_logged_in),
          const SizedBox(height: 10),
          FilledButton(
            child: Text(loginButtonText),
            onPressed: () => navigationService.navigateToSettings(),
          )
        ],
      ),
    );
  }
}
