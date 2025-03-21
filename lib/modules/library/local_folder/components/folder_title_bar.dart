import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/extensions/string.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';

class FolderTitleBar extends ConsumerWidget {
  final String folder;
  final bool isDownloadFolder;
  final bool isCacheFolder;

  const FolderTitleBar({
    super.key,
    required this.folder,
    required this.isDownloadFolder,
    required this.isCacheFolder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Center(
          child: Text(
            isDownloadFolder
                ? context.l10n.downloads
                : isCacheFolder
                    ? context.l10n.cache_folder.capitalize()
                    : basename(folder),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        if (!isDownloadFolder)
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton(
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.more_vert),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(SpotubeIcons.folderRemove),
                    iconColor: colorScheme.error,
                    title: Text(context.l10n.remove_library_location),
                    onTap: () {
                      final libraryLocations = ref
                          .read(userPreferencesProvider)
                          .localLibraryLocation;
                      ref
                          .read(userPreferencesProvider.notifier)
                          .setLocalLibraryLocation(
                            libraryLocations
                                .where((e) => e != folder)
                                .toList(),
                          );
                    },
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}