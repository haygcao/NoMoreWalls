import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/modules/settings/section_card_with_heading.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/spotify/extension/image.dart';
import 'package:spotube/pages/profile/profile.dart';
import 'package:spotube/pages/mobile_login/hooks/login_callback.dart';
import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/provider/scrobbler/scrobbler.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/auth_provider.dart';
import 'package:spotube/utils/service_utils.dart';

class SettingsAccountSection extends HookConsumerWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(context, ref) {
    final theme = Theme.of(context);
    final router = GoRouter.of(context);

    final spotifyAuth = ref.watch(spotifyAuthenticationProvider);
    final youtubeAuth = ref.watch(youtubeMusicAuthProvider);
    final scrobbler = ref.watch(scrobblerProvider);
    final me = ref.watch(meProvider);
    final meData = me.asData?.value;

    final logoutBtnStyle = FilledButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );

    final onSpotifyLogin = useLoginCallback(ref, LoginService.spotify);
    final onYouTubeLogin = useLoginCallback(ref, LoginService.youtubeMusic);

    return SectionCardWithHeading(
      heading: context.l10n.account,
      children: [
        // Spotify 账户部分
        if (spotifyAuth.asData?.value != null)
          ListTile(
            leading: const Icon(SpotubeIcons.spotify),
            title: AutoSizeText(
              context.l10n.user_profile,
              maxLines: 1,
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: UniversalImage.imageProvider(
                  (meData?.images).asUrlString(
                    placeholder: ImagePlaceholder.artist,
                  ),
                ),
              ),
            ),
            onTap: () {
              ServiceUtils.pushNamed(context, ProfilePage.name);
            },
          )
        else
          LayoutBuilder(builder: (context, constrains) {
            return ListTile(
              leading: const Icon(
                SpotubeIcons.spotify,
                color: Colors.green,
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  context.l10n.login_with_spotify,
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              trailing: FilledButton.icon(
                onPressed: constrains.smAndDown ? null : onSpotifyLogin,
                icon: const Icon(SpotubeIcons.spotify),
                label: AutoSizeText(
                  context.l10n.connect,
                  maxLines: 1,
                ),
              ),
              onTap: constrains.mdAndUp ? null : onSpotifyLogin,
            );
          }),

        // YouTube Music 账户部分
        if (youtubeAuth.asData?.value != null)
          ListTile(
            leading: const Icon(SpotubeIcons.youtube),
            title: const AutoSizeText(
              "YouTube Music",
              maxLines: 1,
            ),
            trailing: FilledButton(
              style: logoutBtnStyle,
              onPressed: () {
                ref.read(youtubeMusicAuthProvider.notifier).logout();
              },
              child: AutoSizeText(
                context.l10n.logout,
                maxLines: 1,
              ),
            ),
          )
        else
          ListTile(
            leading: const Icon(
              SpotubeIcons.youtube,
              color: Colors.red,
            ),
            title: const AutoSizeText(
              "YouTube Music",
              maxLines: 1,
            ),
            trailing: FilledButton.icon(
              onPressed: onYouTubeLogin,
              icon: const Icon(SpotubeIcons.youtube),
              label: AutoSizeText(
                context.l10n.connect,
                maxLines: 1,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        // Last.fm 部分保持不变
        if (scrobbler.asData?.value == null)
          ListTile(
            leading: const Icon(SpotubeIcons.lastFm),
            title: Text(context.l10n.login_with_lastfm),
            subtitle: Text(context.l10n.scrobble_to_lastfm),
            trailing: FilledButton.icon(
              icon: const Icon(SpotubeIcons.lastFm),
              label: Text(context.l10n.connect),
              onPressed: () {
                router.push("/lastfm-login");
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 186, 0, 0),
                foregroundColor: Colors.white,
              ),
            ),
          )
        else
          ListTile(
            leading: const Icon(SpotubeIcons.lastFm),
            title: Text(context.l10n.disconnect_lastfm),
            trailing: FilledButton(
              onPressed: () {
                ref.read(scrobblerProvider.notifier).logout();
              },
              style: logoutBtnStyle,
              child: Text(context.l10n.disconnect),
            ),
          ),
      ],
    );
  }
}
