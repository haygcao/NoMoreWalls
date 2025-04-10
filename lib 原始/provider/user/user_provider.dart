import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotube/provider/music_platform.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/provider/youtube_music/youtube_music.dart';
import 'package:spotube/services/base/user.dart';

// 通用用户提供者，根据当前平台返回对应的用户信息
final currentUserProvider = Provider<AsyncValue<UserBase?>>((ref) {
  final currentPlatform = ref.watch(currentMusicPlatformProvider);
  
  switch (currentPlatform) {
    case MusicPlatform.spotify:
      final spotifyUser = ref.watch(meProvider);
      return spotifyUser.whenData((user) => SpotifyUserAdapter(user));
    case MusicPlatform.youtubeMusic:
      final ytMusicUser = ref.watch(youtubeMusicUserProvider);
      return ytMusicUser.whenData((user) => user != null ? YouTubeMusicUserAdapter(user) : null);
    default:
      return const AsyncValue.data(null);
  }
});

// Spotify 用户适配器
class SpotifyUserAdapter implements UserBase {
  final dynamic _user;
  
  SpotifyUserAdapter(this._user);
  
  @override
  String? get id => _user.id;
  
  @override
  String? get name => _user.displayName;
  
  @override
  String? get email => _user.email;
  
  @override
  String? get imageUrl => _user.images?.isNotEmpty == true ? _user.images?.first.url : null;
  
  @override
  String get platform => 'spotify';
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'imageUrl': imageUrl,
    'platform': platform,
  };
}

// YouTube Music 用户适配器
class YouTubeMusicUserAdapter implements UserBase {
  final dynamic _user;
  
  YouTubeMusicUserAdapter(this._user);
  
  @override
  String? get id => _user.id;
  
  @override
  String? get name => _user.name;
  
  @override
  String? get email => null; // YouTube Music API 不提供邮箱
  
  @override
  String? get imageUrl => _user.thumbnailUrl;
  
  @override
  String get platform => 'youtube_music';
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'imageUrl': imageUrl,
    'platform': platform,
  };
}