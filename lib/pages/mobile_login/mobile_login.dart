import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/titlebar/titlebar.dart';
import 'package:spotube/pages/mobile_login/spotify_login_view.dart';
import 'package:spotube/pages/mobile_login/youtube_login_view.dart';

class WebViewLogin extends HookConsumerWidget {
  static const name = "login";
  const WebViewLogin({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TitleBar(
          leading: const [BackButton(color: Colors.white)],
          backgroundColor: Colors.transparent,
          title: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(SpotubeIcons.spotify),
                    const SizedBox(width: 8),
                    const Text('Spotify'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(SpotubeIcons.youtube),
                    const SizedBox(width: 8),
                    const Text('YouTube Music'),
                  ],
                ),
              ),
            ],
          ),
        ),
        extendBodyBehindAppBar: true,
        body: const TabBarView(
          children: [
            SpotifyLoginView(),
            YouTubeMusicLoginView(),
          ],
        ),
      ),
    );
  }
}
