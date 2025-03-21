import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
// 移除直接导入 spotify，只保留带别名的导入
// import 'package:spotify/spotify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/models/spotify/spotify_friends.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/models/spotify/sourceable_track_adapter.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:spotube/services/navigation/navigation_service.dart';

class FriendItem extends HookConsumerWidget {
  final SpotifyFriendActivity friend;
  const FriendItem({
    super.key,
    required this.friend,
  });

  @override
  Widget build(BuildContext context, ref) {
    final ThemeData(
      textTheme: textTheme,
      colorScheme: colorScheme,
    ) = Theme.of(context);

    final spotifyApi = ref.watch(spotifyProvider);
    final navigationService = ref.watch(navigationServiceProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: const BoxConstraints(
        minWidth: 300,
      ),
      height: 80,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: UniversalImage.imageProvider(
              friend.user.imageUrl,
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.user.name,
                style: textTheme.bodyLarge,
              ),
              RichText(
                text: TextSpan(
                  style: textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: friend.track.name,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // 使用 spotify. 前缀创建 Track 和 Artist 实例
                          final spotifyTrack = spotify.Track()
                            ..id = friend.track.id
                            ..name = friend.track.name
                            ..artists = [
                              spotify.Artist()
                                ..id = friend.track.artist.id
                                ..name = friend.track.artist.name
                            ]
                            ..album = spotify.AlbumSimple()
                              ..id = friend.track.album.id
                              ..name = friend.track.album.name;
                          
                          final track = SpotifySourceableTrackAdapter(spotifyTrack);
                          navigationService.navigateToTrack(track);
                        },
                    ),
                    const TextSpan(text: " • "),
                    const WidgetSpan(
                      child: Icon(
                        SpotubeIcons.artist,
                        size: 12,
                      ),
                    ),
                    TextSpan(
                      text: " ${friend.track.artist.name}",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // 使用导航服务
                          navigationService.navigateToArtist(friend.track.artist.id);
                        },
                    ),
                    const TextSpan(text: "\n"),
                    TextSpan(
                      text: friend.track.context.name,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          if (friend.track.context.path.startsWith("album")) {
                            final album = await spotifyApi.albums.get(friend.track.context.id);
                            if (context.mounted) {
                              navigationService.navigateToAlbum(album);
                            }
                          } else {
                            // 对于其他类型的上下文，可能需要添加更多的导航方法
                            // 暂时保留原有逻辑
                            final router = GoRouter.of(context);
                            router.push("/${friend.track.context.path}");
                          }
                        },
                    ),
                    const TextSpan(text: " • "),
                    const WidgetSpan(
                      child: Icon(
                        SpotubeIcons.album,
                        size: 12,
                      ),
                    ),
                    TextSpan(
                      text: " ${friend.track.album.name}",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final album = await spotifyApi.albums.get(friend.track.album.id);
                          if (context.mounted) {
                            navigationService.navigateToAlbum(album);
                          }
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
