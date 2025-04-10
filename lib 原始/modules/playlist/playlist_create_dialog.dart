import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// 移除 Spotify 依赖
// import 'package:spotify/spotify.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/extensions/string.dart';
// 移除 Spotify 图片扩展
// import 'package:spotube/extensions/spotify/image.dart';
// 添加通用图片工具
import 'package:spotube/utils/type/image_type.dart';
// 移除 Spotify 特定 provider
// import 'package:spotube/provider/spotify/spotify.dart';
// import 'package:spotube/provider/spotify/spotify_provider.dart';
// 添加通用播放列表 provider
import 'package:spotube/provider/playlist/playlist_provider.dart';
import 'package:spotube/provider/music_platform.dart';


class PlaylistCreateDialog extends HookConsumerWidget {
  /// Track ids to add to the playlist
  final List<String> trackIds;
  final String? playlistId;
  PlaylistCreateDialog({
    super.key,
    this.trackIds = const [],
    this.playlistId,
  });

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ref) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: HookBuilder(builder: (context) {
          // 使用统一的播放列表提供者
          final currentPlatform = ref.watch(currentMusicPlatformProvider);
          final userPlaylists = ref.watch(currentPlatformPlaylistsProvider);
          final unifiedPlaylistNotifier = ref.watch(unifiedPlaylistProvider.notifier);
          
          // 查找当前编辑的播放列表
          final updatingPlaylist = useMemoized(
            () => userPlaylists.asData?.value
                .firstWhereOrNull((playlist) => playlist.id == playlistId),
            [
              userPlaylists.asData?.value,
              playlistId,
            ],
          );

          final playlistName = useTextEditingController(
            text: updatingPlaylist?.name,
          );
          final description = useTextEditingController(
            text: updatingPlaylist?.description?.unescapeHtml(),
          );
          final public = useState(
            updatingPlaylist?.isPublic ?? false,
          );
          final collaborative = useState(
            updatingPlaylist?.collaborative ?? false,
          );
          final image = useState<XFile?>(null);

          final isUpdatingPlaylist = playlistId != null;

          final l10n = context.l10n;
          final theme = Theme.of(context);
          final scaffold = ScaffoldMessenger.of(context);

          final onError = useCallback((error) {
            scaffold.showSnackBar(
              SnackBar(
                content: Text(
                  l10n.error(error.toString()),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }, [scaffold, l10n, theme]);

          Future<void> onCreate() async {
            if (!formKey.currentState!.validate()) return;

            String? base64Image;
            if (image.value?.path != null) {
              base64Image = await image.value!
                  .readAsBytes()
                  .then((bytes) => base64Encode(bytes));
            }

            try {
              if (isUpdatingPlaylist && playlistId != null) {
                // 修改播放列表
                await unifiedPlaylistNotifier.modifyPlaylist(
                  currentPlatform,
                  playlistId!,
                  playlistName.text,
                  description: description.text,
                  isPublic: public.value,
                  collaborative: collaborative.value,
                  base64Image: base64Image,
                );
              } else {
                // 创建新播放列表
                final newPlaylistId = await unifiedPlaylistNotifier.createPlaylist(
                  currentPlatform,
                  playlistName.text,
                  description: description.text,
                  isPublic: public.value,
                  collaborative: collaborative.value,
                  base64Image: base64Image,
                );
                
                // 如果有曲目要添加到新播放列表
                if (trackIds.isNotEmpty && newPlaylistId != null) {
                  await unifiedPlaylistNotifier.addTracks(
                    currentPlatform,
                    newPlaylistId,
                    trackIds,
                  );
                }
              }
              
              if (context.mounted) {
                context.pop();
              }
            } catch (error) {
              onError(error);
            }
          }

          return AlertDialog(
            title: Text(
              isUpdatingPlaylist
                  ? context.l10n.update_playlist
                  : context.l10n.create_a_playlist,
            ),
            actions: [
              OutlinedButton(
                child: Text(context.l10n.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                onPressed: userPlaylists.isLoading ? null : onCreate,
                child: Text(
                  isUpdatingPlaylist
                      ? context.l10n.update
                      : context.l10n.create,
                ),
              ),
            ],
            insetPadding: const EdgeInsets.all(8),
            content: Container(
              width: MediaQuery.of(context).size.width,
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    FormField<XFile?>(
                        initialValue: image.value,
                        onSaved: (newValue) {
                          image.value = newValue;
                        },
                        validator: (value) {
                          if (value == null) return null;
                          final file = File(value.path);

                          if (file.lengthSync() > 256000) {
                            return "Image size should be less than 256kb";
                          }
                          return null;
                        },
                        builder: (field) {
                          return Column(
                            children: [
                              UniversalImage(
                                path: field.value?.path ??
                                    updatingPlaylist?.imageUrl ??
                                    MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.collection),
                                height: 200,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FilledButton.icon(
                                    icon: const Icon(SpotubeIcons.edit),
                                    label: Text(
                                      field.value?.path != null ||
                                              updatingPlaylist?.imageUrl != null
                                          ? context.l10n.change_cover
                                          : context.l10n.add_cover,
                                    ),
                                    onPressed: () async {
                                      final imageFile = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);

                                      if (imageFile != null) {
                                        field.didChange(imageFile);
                                        field.validate();
                                        field.save();
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton.filled(
                                    icon: const Icon(SpotubeIcons.trash),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.errorContainer,
                                      foregroundColor: theme.colorScheme.error,
                                    ),
                                    onPressed: field.value == null
                                        ? null
                                        : () {
                                            field.didChange(null);
                                            field.validate();
                                            field.save();
                                          },
                                  ),
                                ],
                              ),
                              if (field.hasError)
                                Text(
                                  field.errorText ?? "",
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                )
                            ],
                          );
                        }),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: playlistName,
                      decoration: InputDecoration(
                        hintText: context.l10n.name_of_playlist,
                        labelText: context.l10n.name_of_playlist,
                      ),
                      validator: ValidationBuilder().required().build(),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: description,
                      decoration: InputDecoration(
                        hintText: context.l10n.description,
                      ),
                      keyboardType: TextInputType.multiline,
                      validator: ValidationBuilder().required().build(),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: Text(context.l10n.public),
                      value: public.value,
                      onChanged: (val) => public.value = val ?? false,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: Text(context.l10n.collaborative),
                      value: collaborative.value,
                      onChanged: (val) => collaborative.value = val ?? false,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class PlaylistCreateDialogButton extends HookConsumerWidget {
  const PlaylistCreateDialogButton({super.key});

  showPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlaylistCreateDialog(),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final mediaQuery = MediaQuery.of(context);

    if (mediaQuery.smAndDown) {
      return ElevatedButton(
        style: FilledButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: const Icon(SpotubeIcons.addFilled),
        onPressed: () => showPlaylistDialog(context),
      );
    }

    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      icon: const Icon(SpotubeIcons.addFilled),
      label: Text(context.l10n.create_playlist),
      onPressed: () => showPlaylistDialog(context),
    );
  }
}
