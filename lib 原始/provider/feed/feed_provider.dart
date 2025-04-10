import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/spotify/home_feed.dart';
import 'package:spotube/models/youtube_music/section.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/views/home.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/models/database/database.dart';

/// 统一的Feed Section Provider
/// 根据当前选择的音乐平台返回相应的feed数据
final feedSectionProvider = FutureProvider.family<dynamic, String>(
  (ref, sectionUri) async {
    // 获取当前用户选择的音乐平台
    final preferences = ref.watch(userPreferencesProvider);
    final audioSource = preferences.audioSource;
    
    // 根据不同音源调用不同的provider
    if (audioSource == AudioSource.youtube) {
      // 使用YouTube Music的provider
      final youtubeMusicHome = ref.watch(youtubeMusicHomeProvider);
      final sections = youtubeMusicHome.asData?.value ?? [];
      
      // 查找匹配的section
      return sections.firstWhere(
        (section) => section.id == sectionUri,
        orElse: () => YoutubeMusicSection(
          id: sectionUri,
          title: 'Not Found',
          items: [],
        ),
      );
    } else {
      // 使用Spotify的provider
      final homeView = ref.watch(homeViewProvider);
      final sections = homeView.asData?.value?.sections ?? [];
      
      // 查找匹配的section
      return sections.firstWhere(
        (section) => section.uri == sectionUri,
        orElse: () => SpotifyHomeFeedSection(
          uri: sectionUri,
          title: 'Not Found',
          items: [],
          typename: 'HomeGenericSectionData',
        ),
      );
    }
  },
);