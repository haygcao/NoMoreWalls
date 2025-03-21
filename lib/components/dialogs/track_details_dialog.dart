import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/collections/spotube_icons.dart';

import 'package:spotube/components/links/hyper_link.dart';
import 'package:spotube/components/links/link_text.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/services/base/sourced_track.dart';
import 'package:spotube/extensions/duration.dart';
// 导入通用接口
import 'package:spotube/services/base/sourceable_track.dart';
//import 'package:spotube/services/base/collection.dart';

// 扩展 SourceableTrack 接口，添加我们需要的属性
extension TrackDetailsExtension on SourceableTrack {
  dynamic get album => null;
  String? get releaseDate => null;
  int? get popularity => null;
  List<String>? get artists => [artistName]; // 使用 String 类型的艺术家列表
}

class TrackDetailsDialog extends HookWidget {
  final SourceableTrack track;
  const TrackDetailsDialog({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final detailsMap = {
      context.l10n.title: track.title,
      context.l10n.artist: Text(track.artistName), // 简化为直接显示艺术家名称
      context.l10n.album: LinkText(
        track.albumName ?? '',
        "/album/${track.albumId}",
        extra: track.album,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.blue),
      ),
      context.l10n.duration: (track is SourcedTrack
              ? (track as SourcedTrack).sourceInfo.duration
              : track.duration)
          .toHumanReadableString(),
      if (track.releaseDate != null)
        context.l10n.released: track.releaseDate,
      context.l10n.popularity: track.popularity?.toString() ?? "0",
    };

    final sourceInfo =
        track is SourcedTrack ? (track as SourcedTrack).sourceInfo : null;

    final ytTracksDetailsMap = sourceInfo == null
        ? {}
        : {
            context.l10n.youtube: Hyperlink(
              "https://piped.video/watch?v=${sourceInfo.id}",
              "https://piped.video/watch?v=${sourceInfo.id}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            context.l10n.channel: Hyperlink(
              sourceInfo.artist,
              sourceInfo.artistUrl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            context.l10n.streamUrl: Hyperlink(
              (track as SourcedTrack).url,
              (track as SourcedTrack).url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          };

    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(SpotubeIcons.info),
          const SizedBox(width: 8),
          Text(
            context.l10n.details,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
      content: SizedBox(
        width: mediaQuery.mdAndUp ? double.infinity : 700,
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(95),
            1: FixedColumnWidth(10),
            2: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            for (final entry in detailsMap.entries)
              TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(
                      entry.key,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(":"),
                  ),
                  if (entry.value is Widget)
                    entry.value as Widget
                  else if (entry.value is String)
                    Text(
                      entry.value as String,
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            const TableRow(
              children: [
                SizedBox(height: 16),
                SizedBox(height: 16),
                SizedBox(height: 16),
              ],
            ),
            for (final entry in ytTracksDetailsMap.entries)
              TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(
                      entry.key,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(":"),
                  ),
                  if (entry.value is Widget)
                    entry.value as Widget
                  else
                    Text(
                      entry.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
