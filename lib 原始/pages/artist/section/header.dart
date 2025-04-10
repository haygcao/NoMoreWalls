import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spotube/collections/fake.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/authentication/authentication_provider.dart';
import 'package:spotube/hooks/utils/use_breakpoint_value.dart';
import 'package:spotube/models/database/database.dart';

import 'package:spotube/provider/blacklist_provider.dart';
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/provider/artist/artist_provider.dart';

import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/utils/primitive_utils.dart';

class ArtistPageHeader extends HookConsumerWidget {
  final String artistId;
  const ArtistPageHeader({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, ref) {
    // 使用通用艺术家提供者
    final artistQuery = ref.watch(unifiedArtistProvider(artistId));
    // 正确的类型声明方式
    final Artist artist;
    if (artistQuery.asData?.value != null) {
      artist = artistQuery.asData!.value;
    } else {
      artist = FakeData.artist;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final ThemeData(:textTheme) = theme;

    final chipTextVariant = useBreakpointValue(
      xs: textTheme.bodySmall,
      sm: textTheme.bodySmall,
      md: textTheme.bodyMedium,
      lg: textTheme.bodyLarge,
      xl: textTheme.titleSmall,
      xxl: textTheme.titleMedium,
    );

    // 修复 auth.asData 问题
    final authMap = ref.watch(authenticationProvider);
    final spotifyAuth = authMap[MusicPlatform.spotify];
    final youtubeAuth = authMap[MusicPlatform.youtubeMusic];
    final isAuthenticated = spotifyAuth?.asData?.value != null || youtubeAuth?.asData?.value != null;
    
    ref.watch(blacklistProvider);
    final blacklistNotifier = ref.watch(blacklistProvider.notifier);
    // 使用通用艺术家模型，传入 artist.id
    final isBlackListed = blacklistNotifier.containsArtist(artist.id);

    // 使用 MediaImageUtils 获取图片 URL
    final image = artist.imageUrl ?? 
        MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.artist);

    return LayoutBuilder(
      builder: (context, constrains) {
        return Center(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: constrains.smAndDown
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            direction: constrains.smAndDown ? Axis.vertical : Axis.horizontal,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: kElevationToShadow[2],
                  borderRadius: BorderRadius.circular(35),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: UniversalImage(
                    path: image,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Gap(20),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50)),
                        child: Skeleton.keep(
                          child: Text(
                            "ARTIST", // 使用固定值替代 artist.type
                            style: chipTextVariant.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (isBlackListed) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            context.l10n.blacklisted,
                            style: chipTextVariant.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                  Text(
                    artist.name,
                    style: mediaQuery.smAndDown
                        ? textTheme.headlineSmall
                        : textTheme.headlineMedium,
                  ),
                  Text(
                    context.l10n.followers(
                      PrimitiveUtils.toReadableNumber(
                        artist.platformMetadata?['followers']?.toDouble() ?? 0,
                      ),
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: mediaQuery.mdAndUp ? FontWeight.bold : null,
                    ),
                  ),
                  const Gap(20),
                  Skeleton.keep(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAuthenticated)
                          Consumer(
                            builder: (context, ref, _) {
                              // 使用通用关注艺术家提供者
                              final isFollowingQuery = ref
                                  .watch(isArtistFollowedProvider(artist.id));
                              // 使用正确的提供者
                              final followingArtistNotifier =
                                  ref.watch(followedArtistsNotifierProvider.notifier);

                              return switch (isFollowingQuery) {
                                AsyncData(value: final following) => Builder(
                                    builder: (context) {
                                      if (following) {
                                        return OutlinedButton(
                                          onPressed: () async {
                                            await followingArtistNotifier
                                                .unfollowArtist(artist.id);
                                          },
                                          child: Text(context.l10n.following),
                                        );
                                      }

                                      return FilledButton(
                                        onPressed: () async {
                                          await followingArtistNotifier
                                              .followArtist(artist.id);
                                        },
                                        child: Text(context.l10n.follow),
                                      );
                                    },
                                  ),
                                AsyncError() => const SizedBox(),
                                _ => const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(),
                                  )
                              };
                            },
                          ),
                        const SizedBox(width: 5),
                        IconButton(
                          tooltip: context.l10n.add_artist_to_blacklist,
                          icon: Icon(
                            SpotubeIcons.userRemove,
                            color:
                                !isBlackListed ? Colors.red[400] : Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                isBlackListed ? Colors.red[400] : null,
                          ),
                          onPressed: () async {
                            if (isBlackListed) {
                              await ref
                                  .read(blacklistProvider.notifier)
                                  .remove(artist.id);
                            } else {
                              await ref.read(blacklistProvider.notifier).add(
                                    BlacklistTableCompanion.insert(
                                      name: artist.name,
                                      elementId: artist.id,
                                      elementType: BlacklistedType.artist,
                                    ),
                                  );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(SpotubeIcons.share),
                          onPressed: () async {
                            // 使用通用分享 URL
                            final shareUrl = _getShareUrl(artist);
                            await Clipboard.setData(
                              ClipboardData(
                                text: shareUrl,
                              ),
                            );

                            if (!context.mounted) return;

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                width: 300,
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  context.l10n.artist_url_copied,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 根据艺术家类型获取分享 URL
  String _getShareUrl(Artist artist) {
    // 检查是否是 YouTube Music 艺术家
    if (artist.platformMetadata['type'] == 'youtube_music') {
      return artist.platformMetadata['externalUrls']?['youtube'] ?? 
             "https://music.youtube.com/channel/${artist.id}";
    }
    
    // 默认为 Spotify 艺术家
    return artist.platformMetadata['externalUrls']?['spotify'] ?? 
           "https://open.spotify.com/artist/${artist.id}";
  }
}
