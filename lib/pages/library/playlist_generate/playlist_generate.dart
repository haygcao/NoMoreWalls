import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/models/unified/recommendation.dart';
import 'package:spotube/modules/library/playlist_generate/multi_select_field.dart';
import 'package:spotube/modules/library/playlist_generate/recommendation_attribute_dials.dart';
import 'package:spotube/modules/library/playlist_generate/seeds_multi_autocomplete.dart';
import 'package:spotube/modules/library/playlist_generate/simple_track_tile.dart';
import 'package:spotube/modules/library/playlist_generate/recommendation_attribute_helper.dart';
import 'package:spotube/components/image/universal_image.dart';
import 'package:spotube/components/titlebar/titlebar.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';

import 'package:spotube/provider/category/category_provider.dart';
// 导入统一搜索提供者
import 'package:spotube/provider/search/unified_search_provider.dart';
// 导入统一播放列表提供者
import 'package:spotube/provider/playlist/playlist_provider.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/services/base/artist.dart';

import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/utils/type/image_type.dart';
import 'package:spotube/utils/constants/app_markets.dart';

// 使用正确的 RecommendationAttribute 类型
const RecommendationAttribute zeroValues = RecommendationAttribute(min: 0, target: 0, max: 0);

// 定义生成播放列表的输入参数类
class GeneratePlaylistProviderInput {
  final List<String> seedArtists;
  final List<String> seedTracks;
  final List<String> seedGenres;
  final int limit;
  final RecommendationSeeds max;
  final RecommendationSeeds min;
  final RecommendationSeeds target;

  const GeneratePlaylistProviderInput({
    required this.seedArtists,
    required this.seedTracks,
    required this.seedGenres,
    required this.limit,
    required this.max,
    required this.min,
    required this.target,
  });
}



class PlaylistGeneratorPage extends HookConsumerWidget {
  static const name = "playlist_generator";

  const PlaylistGeneratorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用统一搜索提供者
    final artistSearchProvider = ref.watch(unifiedSearchProvider(SearchType.artist));
    final trackSearchProvider = ref.watch(unifiedSearchProvider(SearchType.track));
    // 使用统一播放列表提供者
    final playlistProvider = ref.watch(unifiedPlaylistProvider);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final preferences = ref.watch(userPreferencesProvider);

    // 使用统一的分类提供者
    final genresCollection = ref.watch(categoryGenresProvider);

    final limit = useValueNotifier<int>(10);
    // 使用 String 类型的市场代码
    final market = useValueNotifier<String>(preferences.market);

    final genres = useState<List<String>>([]);
    // 使用正确的 Artist 类型
    final artists = useState<List<Artist>>([]);
    final tracks = useState<List<SourceableTrack>>([]);

    final enabled =
        genres.value.length + artists.value.length + tracks.value.length < 5;

    final leftSeedCount =
        5 - genres.value.length - artists.value.length - tracks.value.length;

    // 推荐属性
    final min = useState<RecommendationSeeds>(const RecommendationSeeds());
    final max = useState<RecommendationSeeds>(const RecommendationSeeds());
    final target = useState<RecommendationSeeds>(const RecommendationSeeds());

    // 创建辅助方法来生成推荐属性控制器
    Widget createAttributeDials(String attributeName, String title) {
      return RecommendationAttributeDials(
        title: Text(title),
        values: RecommendationAttributeHelper.getAttributeValues(
          targetSeeds: target.value,
          minSeeds: min.value,
          maxSeeds: max.value,
          attributeName: attributeName,
        ),
        onChanged: (value) => RecommendationAttributeHelper.updateAttribute(
          attributeName: attributeName,
          value: value,
          target: target,
          min: min,
          max: max,
        ),
      );
    }

    // 艺术家自动完成组件
    final artistAutoComplete = SeedsMultiAutocomplete<Artist>(
      seeds: artists,
      enabled: enabled,
      inputDecoration: InputDecoration(
        labelText: context.l10n.artists,
        labelStyle: textTheme.titleMedium,
        helperText: context.l10n.select_up_to_count_type(
          leftSeedCount,
          context.l10n.artists,
        ),
      ),
      fetchSeeds: (textEditingValue) async {
        // 使用统一搜索提供者搜索艺术家
        final notifier = ref.read(unifiedSearchProvider(SearchType.artist).notifier);
        await notifier.search(textEditingValue.text);
        final results = artistSearchProvider.value!;
        return results.items.where(
          (element) => artists.value.none((artist) => element.id == artist.id),
        ).cast<Artist>().toList();
      },
      autocompleteOptionBuilder: (option, onSelected) => ListTile(
        leading: CircleAvatar(
          backgroundImage: UniversalImage.imageProvider(
            option.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.artist),
          ),
        ),
        horizontalTitleGap: 20,
        title: Text(option.name),
        // 修复：Artist 没有 genres 属性，使用 platformMetadata 中的 genres 或空列表
        subtitle: option.platformMetadata.containsKey('genres') && 
                 (option.platformMetadata['genres'] as List).isNotEmpty
             ? Wrap(
                 spacing: 4,
                 runSpacing: 4,
                 children: (option.platformMetadata['genres'] as List).mapIndexed(
                   (index, genre) {
                     return Chip(
                       label: Text(genre.toString()),
                       labelStyle: textTheme.bodySmall?.copyWith(
                         color: theme.colorScheme.secondary,
                         fontWeight: FontWeight.w600,
                       ),
                       side: BorderSide.none,
                       backgroundColor: theme.colorScheme.secondaryContainer,
                     );
                   },
                 ).toList(),
               )
             : null,
        onTap: () => onSelected(option),
      ),
      displayStringForOption: (option) => option.name,
      selectedSeedBuilder: (artist) => Chip(
        avatar: CircleAvatar(
          backgroundImage: UniversalImage.imageProvider(
            artist.imageUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.artist),
          ),
        ),
        label: Text(artist.name),
        onDeleted: () {
          artists.value = [
            ...artists.value..removeWhere((element) => element.id == artist.id)
          ];
        },
      ),
    );

    // 曲目自动完成组件
    final tracksAutocomplete = SeedsMultiAutocomplete<SourceableTrack>(
      seeds: tracks,
      enabled: enabled,
      selectedItemDisplayType: SelectedItemDisplayType.list,
      inputDecoration: InputDecoration(
        labelText: context.l10n.tracks,
        labelStyle: textTheme.titleMedium,
        helperText: context.l10n.select_up_to_count_type(
          leftSeedCount,
          context.l10n.tracks,
        ),
      ),
      fetchSeeds: (textEditingValue) async {
        // 使用统一搜索提供者搜索曲目
        final notifier = ref.read(unifiedSearchProvider(SearchType.track).notifier);
        await notifier.search(textEditingValue.text);
        final results = trackSearchProvider.value!;
        return results.items.where(
          (element) => tracks.value.none((track) => element.id == track.id),
        ).cast<SourceableTrack>().toList();
      },
      autocompleteOptionBuilder: (option, onSelected) => ListTile(
        leading: CircleAvatar(
          backgroundImage: UniversalImage.imageProvider(
            option.thumbnailUrl ?? MediaImageUtils.getPlaceholderUrl(ImagePlaceholder.albumArt),
          ),
        ),
        horizontalTitleGap: 20,
        title: Text(option.title),
        // 修复：SourceableTrack 没有 artists 属性，使用 artistName
        subtitle: Text(option.artistName),
        onTap: () => onSelected(option),
      ),
      displayStringForOption: (option) => option.title,
      selectedSeedBuilder: (option) => SimpleTrackTile(
        track: option,
        // 修复：添加 onRemove 回调函数
        onRemove: () {
          tracks.value = [
            ...tracks.value..removeWhere((element) => element.id == option.id)
          ];
        },
      ),
    );

    // 流派选择器
    final genreSelector = MultiSelectField<String>(
      // 将动态类型列表转换为字符串列表
      options: genresCollection.asData?.value
          .map((genre) => genre.toString())
          .toList() ?? [],
      selectedOptions: genres.value,
      getValueForOption: (option) => option,
      onSelected: (value) {
        genres.value = value;
      },
      dialogTitle: Text(context.l10n.select_genres),
      label: Text(context.l10n.add_genres),
      helperText: context.l10n.select_up_to_count_type(
        leftSeedCount,
        context.l10n.genre,
      ),
      enabled: enabled,
    );

    // 国家选择器
    final countrySelector = ValueListenableBuilder(
      valueListenable: market,
      builder: (context, value, _) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: context.l10n.country,
            labelStyle: textTheme.titleMedium,
          ),
          isExpanded: true,
          items: AppMarket.values
              .map(
                (country) => DropdownMenuItem(
                  value: country.code,
                  child: Text(country.displayName),
                ),
              )
              .toList(),
          value: market.value,
          onChanged: (value) {
            if (value != null) market.value = value;
          },
        );
      },
    );

    final controller = useScrollController();




    return Scaffold(
      appBar: PageWindowTitleBar(
        leading: const BackButton(),
        title: Text(context.l10n.generate_playlist),
        centerTitle: true,
      ),
      body: Scrollbar(
        controller: controller,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Breakpoints.lg),
            child: SliderTheme(
              data: const SliderThemeData(
                overlayShape: RoundSliderOverlayShape(),
              ),
              child: SafeArea(
                child: LayoutBuilder(builder: (context, constrains) {
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // 曲目数量选择器
                        ValueListenableBuilder(
                          valueListenable: limit,
                          builder: (context, value, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.number_of_tracks_generate,
                                  style: textTheme.titleMedium,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        value.round().toString(),
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: theme
                                              .colorScheme.primaryContainer,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: value.toDouble(),
                                        min: 10,
                                        max: 100,
                                        divisions: 9,
                                        label: value.round().toString(),
                                        onChanged: (value) {
                                          limit.value = value.round();
                                        },
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // 响应式布局
                        if (constrains.mdAndUp)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: countrySelector,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: genreSelector,
                              ),
                            ],
                          )
                        else ...[
                          countrySelector,
                          const SizedBox(height: 16),
                          genreSelector,
                        ],
                        const SizedBox(height: 16),
                        
                        if (constrains.mdAndUp)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: artistAutoComplete,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: tracksAutocomplete,
                              ),
                            ],
                          )
                        else ...[
                          artistAutoComplete,
                          const SizedBox(height: 16),
                          tracksAutocomplete,
                        ],
                        const SizedBox(height: 16),
                        
                        // 使用辅助方法创建所有推荐属性控制器
                        createAttributeDials('acousticness', context.l10n.acousticness),
                        createAttributeDials('danceability', context.l10n.danceability),
                        createAttributeDials('energy', context.l10n.energy),
                        createAttributeDials('instrumentalness', context.l10n.instrumentalness),
                        createAttributeDials('liveness', context.l10n.liveness),
                        createAttributeDials('loudness', context.l10n.loudness),
                        createAttributeDials('popularity', context.l10n.popularity),
                        createAttributeDials('speechiness', context.l10n.speechiness),
                        createAttributeDials('tempo', context.l10n.tempo),
                        createAttributeDials('valence', context.l10n.valence),
                        
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          icon: const Icon(SpotubeIcons.magic),
                          label: Text(context.l10n.generate_playlist),
                          onPressed: artists.value.isEmpty &&
                                  tracks.value.isEmpty &&
                                  genres.value.isEmpty
                              ? null
                              : () {
                                  final routeState =
                                      GeneratePlaylistProviderInput(
                                    seedArtists: artists.value
                                        .map((a) => a.id ?? "")
                                        .where((id) => id.isNotEmpty)
                                        .toList(),
                                    seedTracks:
                                        tracks.value
                                        .map((t) => t.id ?? "")
                                        .where((id) => id.isNotEmpty)
                                        .toList(),
                                    seedGenres: genres.value,
                                    limit: limit.value,
                                    max: max.value,
                                    min: min.value,
                                    target: target.value,
                                  );
                                  GoRouter.of(context).push(
                                    "/library/generate/result",
                                    extra: routeState,
                                  );
                                },
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
