import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/components/links/anchor_button.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/services/navigation/navigation_service.dart';
import 'package:spotube/services/base/artist.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class ArtistLink extends ConsumerWidget {
  // 修改类型为 Artist
  final List<Artist> artists;
  final WrapCrossAlignment crossAxisAlignment;
  final WrapAlignment mainAxisAlignment;
  final TextStyle textStyle;
  final bool hideOverflowArtist;
  final void Function(String artistId)? onArtistSelected;
  final VoidCallback? onOverflowArtistClick;

  const ArtistLink({
    super.key,
    required this.artists,
    this.crossAxisAlignment = WrapCrossAlignment.center,
    this.mainAxisAlignment = WrapAlignment.center,
    this.textStyle = const TextStyle(),
    this.onArtistSelected,
    this.hideOverflowArtist = true,
    this.onOverflowArtistClick,
  }) : assert(hideOverflowArtist ? onOverflowArtistClick != null : true);

  // 添加一个工厂构造函数，从 SourceableTrack 创建 ArtistLink
  factory ArtistLink.fromTrack({
    Key? key,
    required SourceableTrack track,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.center,
    WrapAlignment mainAxisAlignment = WrapAlignment.center,
    TextStyle textStyle = const TextStyle(),
    void Function(String artistId)? onArtistSelected,
    bool hideOverflowArtist = true,
    VoidCallback? onOverflowArtistClick,
  }) {
    // 从 track 中提取艺术家信息
    // 这里假设 track.artistName 可能包含多个艺术家，用逗号分隔
    final artistNames = track.artistName.split(',').map((e) => e.trim()).toList();
    
    // 创建 Artist 列表
    final artists = [
      Artist(
        id: track.artistId ?? '',
        name: artistNames.first,
        uri: 'spotify:artist:${track.artistId ?? ''}',
      ),
      // 如果有多个艺术家名但没有对应的ID，则只使用名称
      ...artistNames.skip(1).map((name) => Artist(
        id: '', // 空ID
        name: name,
        uri: '',
      ))
    ];
    
    return ArtistLink(
      key: key,
      artists: artists,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      textStyle: textStyle,
      onArtistSelected: onArtistSelected,
      hideOverflowArtist: hideOverflowArtist,
      onOverflowArtistClick: onOverflowArtistClick,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData(:colorScheme) = Theme.of(context);
    final navigationService = ref.watch(navigationServiceProvider);

    return Wrap(
      crossAxisAlignment: crossAxisAlignment,
      alignment: mainAxisAlignment,
      children: [
        ...(hideOverflowArtist ? artists.take(3).toList() : artists)
            .asMap()
            .entries
            .map(
              (artist) => Builder(builder: (context) {
                if (artist.value.name.isEmpty) {
                  return Text("未知艺术家", style: textStyle);
                }
                return AnchorButton(
                  (artist.key != artists.length - 1)
                      ? "${artist.value.name}, "
                      : artist.value.name,
                  onTap: () {
                    if (artist.value.id.isEmpty) {
                      // 如果没有艺术家ID，则不执行任何操作
                      return;
                    }
                    
                    if (onArtistSelected != null) {
                      onArtistSelected?.call(artist.value.id);
                    } else {
                      navigationService.navigateToArtist(artist.value.id);
                    }
                  },
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                );
              }),
            ),
        if (hideOverflowArtist && artists.length > 3)
          AnchorButton(
            context.l10n.and_n_more(artists.length - 3),
            onTap: () {
              onOverflowArtistClick?.call();
            },
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(
              color: colorScheme.secondary,
              decoration: TextDecoration.underline,
            ),
          ),
      ],
    );
  }
}
