/// 缓存键
class CacheKeys {
  /// 音轨缓存键前缀
  static const String trackPrefix = 'track_';
  
  /// 专辑缓存键前缀
  static const String albumPrefix = 'album_';
  
  /// 艺术家缓存键前缀
  static const String artistPrefix = 'artist_';
  
  /// 播放列表缓存键前缀
  static const String playlistPrefix = 'playlist_';
  
  /// 用户缓存键前缀
  static const String userPrefix = 'user_';
  
  /// 搜索结果缓存键前缀
  static const String searchPrefix = 'search_';
  
  /// 图片缓存键前缀
  static const String imagePrefix = 'image_';
  
  /// 音频缓存键前缀
  static const String audioPrefix = 'audio_';
  
  /// 生成音轨缓存键
  static String trackKey(String trackId, String platformId) => '$trackPrefix${platformId}_$trackId';
  
  /// 生成专辑缓存键
  static String albumKey(String albumId, String platformId) => '$albumPrefix${platformId}_$albumId';
  
  /// 生成艺术家缓存键
  static String artistKey(String artistId, String platformId) => '$artistPrefix${platformId}_$artistId';
  
  /// 生成播放列表缓存键
  static String playlistKey(String playlistId, String platformId) => '$playlistPrefix${platformId}_$playlistId';
  
  /// 生成用户缓存键
  static String userKey(String userId, String platformId) => '$userPrefix${platformId}_$userId';
  
  /// 生成搜索结果缓存键
  static String searchKey(String query, String platformId) => '$searchPrefix${platformId}_$query';
  
  /// 生成图片缓存键
  static String imageKey(String url) => '$imagePrefix${url.hashCode}';
  
  /// 生成音频缓存键
  static String audioKey(String url) => '$audioPrefix${url.hashCode}';
}