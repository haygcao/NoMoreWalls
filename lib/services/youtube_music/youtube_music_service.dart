import 'package:dio/dio.dart';
import 'package:spotube/models/youtube_music/category.dart';
import 'package:spotube/models/youtube_music/credentials.dart';
import 'package:spotube/models/youtube_music/user.dart';
import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotube/models/youtube_music/album.dart';
import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/models/youtube_music/channel.dart';
import 'package:spotube/models/youtube_music/library.dart';
import 'package:spotube/models/youtube_music/search.dart';
import 'package:spotube/models/youtube_music/section.dart'; // 添加 section 模型导入
import 'package:spotube/services/logger/logger.dart';


class YoutubeMusicService {
  final YoutubeMusicCredentials? credentials;
  final Dio _dio;
  static const String _baseUrl = 'https://music.youtube.com/youtubei/v1';
  // 添加喜欢音轨方法
  Future<void> likeTrack(String trackId) async {
    await _dio.post('/like', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'target': {
        'videoId': trackId
      },
      'likeStatus': 'LIKE'
    });
  }
  // 取消喜欢音轨方法
  Future<void> unlikeTrack(String trackId) async {
    await _dio.post('/like', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'target': {
        'videoId': trackId
      },
      'likeStatus': 'INDIFFERENT'
    });
  }
  YoutubeMusicService({this.credentials}) : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      if (credentials != null) ...credentials!.cookies,
    };
  }
  factory YoutubeMusicService.anonymous() {
    return YoutubeMusicService();
  }
  // 用户相关
  Future<YoutubeMusicUser?> getCurrentUser() async {
    if (credentials == null) return null;
    try {
      final response = await _dio.post('/browse', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
      });
      return YoutubeMusicUser.fromJson(response.data['user']);
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return null;
    }
  }
  Future<YoutubeMusicLibrary> getUserLibrary() async {
    try {
      final response = await _dio.post('/browse', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'browseId': 'FEmusic_liked',
      });
      return YoutubeMusicLibrary.fromJson(response.data);
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return const YoutubeMusicLibrary(playlists: [], albums: [], likedTracks: []);
    }
  }
  // 专辑相关
  Future<YoutubeMusicAlbum> getAlbum(String albumId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': albumId,
    });
    return YoutubeMusicAlbum.fromJson(response.data);
  }
  Future<List<YoutubeMusicTrack>> getAlbumTracks(String albumId) async {
    final album = await getAlbum(albumId);
    return album.tracks;
  }
  Future<List<YoutubeMusicAlbum>> getNewReleases() async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': 'FEmusic_new_releases',
    });
    return (response.data['albums'] as List)
        .map((album) => YoutubeMusicAlbum.fromJson(album))
        .toList();
  }
  // 艺人相关
  Future<List<YoutubeMusicAlbum>> getArtistAlbums(String artistId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': artistId,
      'params': 'EgWKAQIYAlAB',  // 专辑过滤参数
    });
    return (response.data['albums'] as List)
        .map((album) => YoutubeMusicAlbum.fromJson(album))
        .toList();
  }
  Future<List<YoutubeMusicChannel>> getFollowedArtists() async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': 'FEmusic_library_subscriptions',
    });
    return (response.data['artists'] as List)
        .map((artist) => YoutubeMusicChannel.fromJson(artist))
        .toList();
  }
  Future<bool> isFollowingArtist(String artistId) async {
    final artists = await getFollowedArtists();
    return artists.any((artist) => artist.id == artistId);
  }
  // 分类相关
  Future<List<YoutubeMusicCategory>> getCategories() async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': 'FEmusic_moods_and_genres',
    });
    return (response.data['categories'] as List)
        .map((category) => YoutubeMusicCategory.fromJson(category))
        .toList();
  }
  Future<List<YoutubeMusicPlaylist>> getCategoryPlaylists(String categoryId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': categoryId,
    });
    return (response.data['playlists'] as List)
        .map((playlist) => YoutubeMusicPlaylist.fromJson(playlist))
        .toList();
  }
  // Fix in getArtist method
  Future<YoutubeMusicChannel> getArtist(String artistId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': artistId,
    });
    
    final data = response.data;
    final header = data['header']['musicImmersiveHeaderRenderer'];
    final description = data['header']['description']?['runs']?[0]?['text'];
    
    // Extract subscriber count text and convert to int
    final subscriberText = header['subscriptionButton']['subscribeButtonRenderer']['subscriberCountText']['runs'][0]['text'];
    // Parse the subscriber count - remove non-numeric characters and convert to int
    final subscriberCount = int.tryParse(subscriberText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    
    return YoutubeMusicChannel(
      id: artistId,
      name: header['title']['runs'][0]['text'],
      description: description,
      thumbnailUrl: header['thumbnail']['musicThumbnailRenderer']['thumbnail']['thumbnails'].last['url'],
      subscriberCount: subscriberCount, // Changed from string to int
    );
  }
  // 修改 getArtistTopTracks 中的 track 创建
  Future<List<YoutubeMusicTrack>> getArtistTopTracks(String artistId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': artistId,
      'params': 'EgWKAQIIAWoKEAMQBBAJEAoQBQ', // 热门歌曲过滤参数
    });
  
    final tracks = response.data['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'][0]['musicShelfRenderer']['contents'];
  
    return (tracks as List).map((track) {
      final details = track['musicResponsiveListItemRenderer'];
      final videoId = details['playlistItemData']['videoId'];
      
      return YoutubeMusicTrack(
        id: videoId,
        title: details['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        thumbnailUrl: details['thumbnail']['musicThumbnailRenderer']
            ['thumbnail']['thumbnails'].last['url'],
        duration: Duration(seconds: int.parse(details['fixedColumns'][0]
            ['musicResponsiveListItemFixedColumnRenderer']['text']['runs'][0]['text'])),
        channelId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
        channelName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        viewCount: 0, // YouTube Music API 不提供播放次数
        publishedAt: DateTime.now(), // YouTube Music API 不提供发布时间
        artistId: artistId,
        artistName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        tags: [], // 可选参数，使用默认值
      );
    }).toList();
  }
  // 播放列表相关方法
  Future<YoutubeMusicPlaylist> getPlaylist(String playlistId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': playlistId,
    });
    
    final data = response.data;
    final header = data['header']['musicDetailHeaderRenderer'];
    
    return YoutubeMusicPlaylist(
      id: playlistId,
      title: header['title']['runs'][0]['text'],
      description: header['description']?['runs']?[0]?['text'],
      thumbnailUrl: header['thumbnail']['musicThumbnailRenderer']
          ['thumbnail']['thumbnails'].last['url'],
      authorId: header['subtitle']['runs'][2]['navigationEndpoint']
          ['browseEndpoint']['browseId'],
      authorName: header['subtitle']['runs'][2]['text'],
      trackCount: int.parse(header['secondSubtitle']['runs'][0]['text']
          .split(' ')[0]),
      createdAt: DateTime.now(), // YouTube Music API 不提供创建时间
      updatedAt: DateTime.now(), // YouTube Music API 不提供更新时间
      tracks: [], // 需要通过 getPlaylistTracks 获取
    );
  }
  // 修改 getPlaylistTracks 中的 track 创建
  Future<List<YoutubeMusicTrack>> getPlaylistTracks(String playlistId) async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': playlistId,
    });
  
    final tracks = response.data['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'][0]['musicPlaylistShelfRenderer']['contents'];
  
    return (tracks as List).map((track) {
      final details = track['musicResponsiveListItemRenderer'];
      final videoId = details['playlistItemData']['videoId'];
      
      return YoutubeMusicTrack(
        id: videoId,
        title: details['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        thumbnailUrl: details['thumbnail']['musicThumbnailRenderer']
            ['thumbnail']['thumbnails'].last['url'],
        duration: Duration(seconds: int.parse(details['fixedColumns'][0]
            ['musicResponsiveListItemFixedColumnRenderer']['text']['runs'][0]['text'])),
        channelId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
        channelName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        viewCount: 0, // YouTube Music API 不提供播放次数
        publishedAt: DateTime.now(), // YouTube Music API 不提供发布时间
        artistId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
        artistName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
      );
    }).toList();
  }
  // 获取用户播放列表
  Future<List<YoutubeMusicPlaylist>> getUserPlaylists() async {
    final library = await getUserLibrary();
    return library.playlists;
  }
  // 添加音轨到播放列表
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    try {
      await _dio.post('/playlist/edit', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'actions': [{
          'action': 'ACTION_ADD_VIDEO',
          'addedVideoId': trackId
        }],
        'playlistId': playlistId
      });
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }
  // 从播放列表移除音轨
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    try {
      await _dio.post('/playlist/edit', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'actions': [{
          'action': 'ACTION_REMOVE_VIDEO',
          'removedVideoId': trackId
        }],
        'playlistId': playlistId
      });
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }
  // 创建播放列表
  Future<YoutubeMusicPlaylist> createPlaylist(String name, {String? description}) async {
    try {
      final response = await _dio.post('/playlist/create', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'title': name,
        'description': description ?? '',
        'privacyStatus': 'PRIVATE'
      });
      final playlistId = response.data['playlistId'];
      return YoutubeMusicPlaylist(
        id: playlistId,
        title: name,
        description: description ?? '',
        thumbnailUrl: '',
        authorId: '',
        authorName: '',
        trackCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tracks: const [],
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      throw Exception('创建播放列表失败');
    }
  }
  
  // 修改播放列表
  Future<void> modifyPlaylist(String playlistId, String name, {String? description}) async {
    try {
      await _dio.post('/browse/edit_playlist', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'playlistId': playlistId,
        'title': name,
        'description': description ?? '',
      });
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      throw Exception('修改播放列表失败: $e');
    }
  }
  
  // 删除播放列表
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _dio.post('/playlist/delete', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'playlistId': playlistId
      });
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
    }
  }
  // 获取电台音轨
  Future<List<YoutubeMusicTrack>> getRadioTracks(String trackId) async {
    try {
      final response = await _dio.post('/next', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'videoId': trackId,
        'params': 'wAEB8gECGAE%3D'
      });
      final contents = response.data['contents']['singleColumnMusicWatchNextResultsRenderer']
          ['tabbedRenderer']['watchNextTabbedResultsRenderer']
          ['tabs'][0]['tabRenderer']['content']['musicQueueRenderer']
          ['content']['playlistPanelRenderer']['contents'];
      return (contents as List).map((item) {
        try {
          final details = item['playlistPanelVideoRenderer'];
          return YoutubeMusicTrack(
            id: details['videoId'],
            title: details['title']['runs'][0]['text'],
            thumbnailUrl: details['thumbnail']['thumbnails'].last['url'],
            duration: Duration(seconds: int.parse(details['lengthText']['runs'][0]['text']
                .split(':')
                .fold(0, (p, e) => p * 60 + int.parse(e)))),
            channelId: details['shortBylineText']['runs'][0]['navigationEndpoint']
                ['browseEndpoint']['browseId'],
            channelName: details['shortBylineText']['runs'][0]['text'],
            viewCount: 0,
            publishedAt: DateTime.now(),
            artistId: details['shortBylineText']['runs'][0]['navigationEndpoint']
                ['browseEndpoint']['browseId'],
            artistName: details['shortBylineText']['runs'][0]['text'],
          );
        } catch (e) {
          AppLogger.reportError(e, StackTrace.current);
          return null;
        }
      }).whereType<YoutubeMusicTrack>().toList();
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      return [];
    }
  }
  // 修改 getLikedTracks 中的 track 创建
  Future<List<YoutubeMusicTrack>> getLikedTracks() async {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': 'FEmusic_liked_videos',
    });
  
    final tracks = response.data['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'][0]['musicShelfRenderer']['contents'];
  
    return (tracks as List).map((track) {
      final details = track['musicResponsiveListItemRenderer'];
      final videoId = details['playlistItemData']['videoId'];
      
      return YoutubeMusicTrack(
        id: videoId,
        title: details['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        thumbnailUrl: details['thumbnail']['musicThumbnailRenderer']
            ['thumbnail']['thumbnails'].last['url'],
        duration: Duration(seconds: int.parse(details['fixedColumns'][0]
            ['musicResponsiveListItemFixedColumnRenderer']['text']['runs'][0]['text'])),
        channelId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
        channelName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
        viewCount: 0,
        publishedAt: DateTime.now(),
        artistId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
        artistName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
            ['text']['runs'][0]['text'],
      );
    }).toList();
  }
  // 搜索相关方法
  Future<YoutubeMusicSearchResults> search(String query) async {
    final response = await _dio.post('/search', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'query': query,
    });
  
    final results = response.data['contents']['tabbedSearchResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
        ['contents'];
  
    List<YoutubeMusicTrack> tracks = [];
    List<YoutubeMusicAlbum> albums = [];
    List<YoutubeMusicChannel> artists = [];
    List<YoutubeMusicPlaylist> playlists = [];
  
    for (final section in results) {
      final sectionContent = section['musicShelfRenderer'];
      final items = sectionContent['contents'];
      final title = sectionContent['title']['runs'][0]['text'];
  
      switch (title) {
        case 'Songs':
          tracks = (items as List).map((item) {
            final details = item['musicResponsiveListItemRenderer'];
            return YoutubeMusicTrack(
              id: details['playlistItemData']['videoId'],
              title: details['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']
                  ['text']['runs'][0]['text'],
              thumbnailUrl: details['thumbnail']['musicThumbnailRenderer']
                  ['thumbnail']['thumbnails'].last['url'],
              duration: Duration(seconds: int.parse(details['fixedColumns'][0]
                  ['musicResponsiveListItemFixedColumnRenderer']['text']['runs'][0]['text'])),
              channelId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
                  ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
              channelName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
                  ['text']['runs'][0]['text'],
              viewCount: 0,
              publishedAt: DateTime.now(),
              artistId: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
                  ['text']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId'],
              artistName: details['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']
                  ['text']['runs'][0]['text'],
            );
          }).toList();
          break;
        // ... 其他类型的处理 ...
      }
    }
  
    return YoutubeMusicSearchResults(
      tracks: tracks,
      albums: albums,
      artists: artists,
      playlists: playlists,
    );
  }
  Future<List<String>> getSearchSuggestions(String query) async {
    final response = await _dio.post('/music/get_search_suggestions', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'input': query,
    });
  
    return (response.data['suggestions'] as List)
        .map((suggestion) => suggestion['text'] as String)
        .toList();
  }

// 获取首页内容
Future<List<YoutubeMusicSection>> getHomeContent() async {
  try {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': 'FEmusic_home',
    });
    
    final List<YoutubeMusicSection> sections = [];
    
    final contents = response.data['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']['contents'];
    
    for (final content in contents) {
      if (content['musicCarouselShelfRenderer'] != null) {
        final shelfRenderer = content['musicCarouselShelfRenderer'];
        final title = shelfRenderer['header']['musicCarouselShelfBasicHeaderRenderer']
            ['title']['runs'][0]['text'];
        final sectionId = title.replaceAll(' ', '_').toLowerCase();
        final items = <dynamic>[];
        
        for (final item in shelfRenderer['contents']) {
          final renderer = item['musicTwoRowItemRenderer'];
          if (renderer != null) {
            final navigationEndpoint = renderer['navigationEndpoint'];
            final browseEndpoint = navigationEndpoint['browseEndpoint'];
            final watchEndpoint = navigationEndpoint['watchEndpoint'];
            
            String id = '';
            String type = '';
            
            if (browseEndpoint != null) {
              id = browseEndpoint['browseId'];
              if (id.startsWith('MPREb')) {
                type = 'album';
              } else if (id.startsWith('MPRE')) {
                type = 'playlist';
              } else if (id.startsWith('UC')) {
                type = 'artist';
              }
            } else if (watchEndpoint != null) {
              id = watchEndpoint['videoId'];
              type = 'track';
            }
            
            if (id.isNotEmpty) {
              final title = renderer['title']['runs'][0]['text'];
              final subtitle = renderer['subtitle']['runs']
                  .map((run) => run['text'])
                  .join(' ');
              final thumbnailUrl = renderer['thumbnailRenderer']['musicThumbnailRenderer']
                  ['thumbnail']['thumbnails'].last['url'];
              
              switch (type) {
                case 'album':
                  items.add(YoutubeMusicAlbum(
                    id: id,
                    title: title,
                    thumbnailUrl: thumbnailUrl,
                    artistName: subtitle,
                    artistId: '',
                    tracks: [],
                    releaseDate: DateTime.now(), // Changed from String to DateTime
                    // Removed the 'year' parameter as it doesn't exist
                  ));
                  break;
                case 'playlist':
                  items.add(YoutubeMusicPlaylist(
                    id: id,
                    title: title,
                    thumbnailUrl: thumbnailUrl,
                    authorName: subtitle,
                    authorId: '',
                    tracks: [],
                    trackCount: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ));
                  break;
                case 'artist':
                  items.add(YoutubeMusicChannel(
                    id: id,
                    name: title,
                    thumbnailUrl: thumbnailUrl,
                    subscriberCount: 0, // Changed from string to int
                  ));
                  break;
                case 'track':
                  items.add(YoutubeMusicTrack(
                    id: id,
                    title: title,
                    thumbnailUrl: thumbnailUrl,
                    artistName: subtitle,
                    artistId: '',
                    channelId: '',
                    channelName: subtitle,
                    duration: const Duration(minutes: 3), // 默认时长
                    viewCount: 0,
                    publishedAt: DateTime.now(),
                  ));
                  break;
              }
            }
          }
        }
        
        if (items.isNotEmpty) {
          sections.add(YoutubeMusicSection(
            id: sectionId,
            title: title,
            items: items,
          ));
        }
      }
    }
    
    return sections;
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return [];
  }
}

// 获取分区内容
Future<YoutubeMusicSection> getSectionContent(String sectionId) async {
  try {
    // 这里需要根据 sectionId 获取更多内容
    // 实际实现可能需要调用不同的 API
    return YoutubeMusicSection(
      id: sectionId,
      title: sectionId.replaceAll('_', ' '),
      items: [],
    );
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return YoutubeMusicSection(
      id: sectionId,
      title: sectionId.replaceAll('_', ' '),
      items: [],
    );
  }
}

// 添加内容到库中（专辑、歌曲等）
Future<void> addToLibrary(String entityType, String entityId) async {
  try {
    await _dio.post('/browse/edit', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'actions': [{
        'action': 'ACTION_ADD_LIBRARY',
        'entityType': entityType,
        'entityId': entityId
      }]
    });
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    throw Exception('添加到收藏失败: $e');
  }
}

// 从库中移除内容（专辑、歌曲等）
Future<void> removeFromLibrary(String entityType, String entityId) async {
  try {
    await _dio.post('/browse/edit', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'actions': [{
        'action': 'ACTION_REMOVE_LIBRARY',
        'entityType': entityType,
        'entityId': entityId
      }]
    });
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    throw Exception('从收藏中移除失败: $e');
  }
}

// 检查专辑是否已收藏
Future<bool> isAlbumInLibrary(String albumId) async {
  try {
    final library = await getUserLibrary();
    return library.albums.any((album) => album.id == albumId);
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return false;
  }
}



// 添加关注艺术家方法
Future<void> subscribeToChannel(String channelId) async {
  try {
    await _dio.post('/subscription/subscribe', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'channelIds': [channelId]
    });
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    throw Exception('关注艺术家失败: $e');
  }
}

// 添加取消关注艺术家方法
Future<void> unsubscribeFromChannel(String channelId) async {
  try {
    await _dio.post('/subscription/unsubscribe', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'channelIds': [channelId]
    });
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    throw Exception('取消关注艺术家失败: $e');
  }
}

// 添加获取相关艺术家方法
Future<List<YoutubeMusicChannel>> getRelatedArtists(String artistId) async {
  try {
    final response = await _dio.post('/browse', data: {
      'context': {'client': {'clientName': 'WEB_REMIX'}},
      'browseId': artistId,
      'params': 'EgWKAQI%3D', // 相关艺术家过滤参数
    });
    
    // 尝试从响应中提取相关艺术家部分
    final contents = response.data['contents']['singleColumnBrowseResultsRenderer']
        ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']['contents'];
    
    // 查找包含相关艺术家的部分
    for (final section in contents) {
      if (section['musicCarouselShelfRenderer'] != null) {
        final shelfRenderer = section['musicCarouselShelfRenderer'];
        final title = shelfRenderer['header']['musicCarouselShelfBasicHeaderRenderer']
            ['title']['runs'][0]['text'];
        
        // 检查是否是相关艺术家部分
        if (title.contains('相关') || title.contains('Similar') || title.contains('Related')) {
          final items = shelfRenderer['contents'];
          final relatedArtists = <YoutubeMusicChannel>[];
          
          for (final item in items) {
            final renderer = item['musicTwoRowItemRenderer'];
            if (renderer != null) {
              final navigationEndpoint = renderer['navigationEndpoint'];
              final browseEndpoint = navigationEndpoint['browseEndpoint'];
              
              if (browseEndpoint != null) {
                final id = browseEndpoint['browseId'];
                // 确保这是一个艺术家ID
                if (id.startsWith('UC')) {
                  final name = renderer['title']['runs'][0]['text'];
                  final thumbnailUrl = renderer['thumbnailRenderer']['musicThumbnailRenderer']
                      ['thumbnail']['thumbnails'].last['url'];
                  
                  relatedArtists.add(YoutubeMusicChannel(
                    id: id,
                    name: name,
                    thumbnailUrl: thumbnailUrl,
                    subscriberCount: 0, // 这里无法获取订阅数
                  ));
                }
              }
            }
          }
          
          return relatedArtists;
        }
      }
    }
    
    // 如果没有找到相关艺术家部分
    return [];
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return [];
  }
}

// 获取艺术家信息和相关艺术家
Future<Map<String, dynamic>> getArtistInfo(String artistId) async {
  try {
    final artist = await getArtist(artistId);
    final relatedArtists = await getRelatedArtists(artistId);
    
    return {
      'artist': artist,
      'relatedArtists': relatedArtists,
    };
  } catch (e, stack) {
    AppLogger.reportError(e, stack);
    return {
      'artist': null,
      'relatedArtists': <YoutubeMusicChannel>[],
    };
  }
}


  // Add getTrack method
  Future<YoutubeMusicTrack> getTrack(String trackId) async {
    try {
      final response = await _dio.post('/player', data: {
        'context': {'client': {'clientName': 'WEB_REMIX'}},
        'videoId': trackId,
      });

      final data = response.data;
      final videoDetails = data['videoDetails'];
      
      return YoutubeMusicTrack(
        id: trackId,
        title: videoDetails['title'],
        thumbnailUrl: videoDetails['thumbnail']['thumbnails'].last['url'],
        duration: Duration(seconds: int.parse(videoDetails['lengthSeconds'])),
        channelId: videoDetails['channelId'],
        channelName: videoDetails['author'],
        viewCount: int.parse(videoDetails['viewCount']),
        publishedAt: DateTime.now(), // API doesn't provide publish date
        artistId: videoDetails['channelId'],
        artistName: videoDetails['author'],
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      throw Exception('Failed to get track: $e');
    }
  }
}