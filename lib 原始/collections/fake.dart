import 'package:spotify/spotify.dart';
import 'package:spotube/models/database/database.dart';
import 'package:spotube/models/spotify/home_feed.dart';
import 'package:spotube/models/spotify/spotify_friends.dart';
import 'package:spotube/provider/history/summary.dart';
import 'package:spotube/services/base/sourceable_track.dart';
// 添加 Album 类的导入
import 'package:spotube/services/base/album.dart' as base;  // 给我们的 Album 添加前缀
import 'package:spotube/services/base/artist.dart' as spotube_artist;  // 修改导入，添加前缀避免冲突
import 'package:spotube/services/base/playlist.dart' as spotube_playlist;
import 'package:spotube/services/base/user.dart' as base_user;  // 导入通用用户模型

abstract class FakeData {
  static final Image image = Image()
    ..height = 1
    ..width = 1
    ..url = "https://dummyimage.com/100x100/cfcfcf/cfcfcf.jpg";
    
// 在 FakeData 类中添加，将 ArtistBase 改为 Artist
static final artistFake = spotube_artist.Artist(
  id: "1",
  name: "What an artist",
  imageUrl: image.url,
  uri: "uri",
  platformMetadata: {
    'type': 'artist',
    'href': 'text',
    'externalUrls': {'spotify': 'text'},
  },
);

  //  spotifyArtist 
  static final spotifyArtist = Artist()
    ..id = "1"
    ..name = "What an artist"
    ..type = "type"
    ..uri = "uri"
    ..externalUrls = externalUrls;

  // 添加一个新的 artist 字段，使用 spotube_artist.Artist 类型
  static final artist = spotube_artist.Artist(
    id: "1",
    name: "What an artist",
    imageUrl: image.url,
    uri: "uri",
    platformMetadata: {
      'type': 'artist',
      'href': 'text',
      'externalUrls': {'spotify': 'text'},
      'followers': 1000,
    },
  );

  // 添加基于 services/base/album.dart 的 Album 实现
static final album = base.Album(
    id: "1",
    name: "A good album",
    uri: "uri",
    description: "A fake album for testing",
    imageUrl: image.url,
    releaseDate: DateTime.parse("2021-01-01"),
    artists: ["What an artist"],
    albumType: "album",
    tracks: [sourceableTrack],
    platformMetadata: {
      'type': 'album',
      'href': 'text',
      'externalUrls': {'spotify': 'text'},
    },
  );

  // 添加通用 Playlist 实现
  static final playlist = spotube_playlist.Playlist(
    id: "1",
    name: "A good playlist",
    description: "A fake playlist for testing",
    imageUrl: image.url,
    uri: "spotify:playlist:1",
    isPublic: false,
    collaborative: false,
    owner: "Test User",
    totalTracks: 0,
    platformMetadata: {
      'platform': 'spotify',
      'type': 'playlist',
      'href': 'text',
      'externalUrls': {'spotify': 'text'},
    },
  );

  // 添加通用spotify Playlist 实现
  static final PlaylistSimple playlistSimple = PlaylistSimple()
    ..id = "1"
    ..name = "A good playlist"
    ..description = "A fake playlist for testing"
    ..type = "playlist"
    ..collaborative = false
    ..public = false
    ..images = [image];
  static final externalUrls = ExternalUrls()..spotify = "text";
  static final AlbumSimple albumSimple = AlbumSimple()
    ..id = "1"
    ..albumType = AlbumType.album
    ..artists = [spotifyArtist] // 修改这里，使用 spotifyArtist 而不是 artist
    ..availableMarkets = [Market.BD]
    ..externalUrls = externalUrls
    ..href = "text"
    ..images = [image]
    ..name = "A good album"
    ..releaseDate = "2021-01-01"
    ..releaseDatePrecision = DatePrecision.day
    ..type = "type"
    ..uri = "uri";
  // 通用接口实现
  static final sourceableTrack = SourcedTrackImpl(
    id: "1",
    title: "A Track Name",
    artistName: "What an artist",
    albumName: "A good album",
    duration: const Duration(milliseconds: 50000),
    thumbnailUrl: image.url,  // 使用 image.url 替代 _dummyImageUrl
    albumId: albumSimple.id,
    artistId: artist.id,
  );
  
  // 添加一个新的 fakeTrack 字段，类型为 SourceableTrack
  static final fakeTrack = _FakeTrack();
  
  // Spotify 特定实现
  static final Track track = Track()
    ..id = sourceableTrack.id
    ..name = sourceableTrack.title
    ..artists = [spotifyArtist]  // 修改这里，使用 spotifyArtist 而不是 artist
    ..album = albumSimple
    ..durationMs = sourceableTrack.duration.inMilliseconds;
  static final friends = SpotifyFriends(
    friends: [
      for (var i = 0; i < 3; i++)
        SpotifyFriendActivity(
          user: const SpotifyFriend(
            name: "name",
            imageUrl: "imageUrl",
            uri: "uri",
          ),
          track: SpotifyActivityTrack(
            name: "name",
            artist: const SpotifyActivityArtist(
              name: "name",
              uri: "uri",
            ),
            album: const SpotifyActivityAlbum(
              name: "name",
              uri: "uri",
            ),
            context: SpotifyActivityContext(
              name: "name",
              index: i,
              uri: "uri",
            ),
            imageUrl: "imageUrl",
            uri: "uri",
          ),
        ),
    ],
  );
  static final feedSection = SpotifyHomeFeedSection(
    typename: "HomeGenericSectionData",
    uri: "spotify:section:lol",
    title: "Dummy",
    items: [
      for (int i = 0; i < 10; i++)
        SpotifyHomeFeedSectionItem(
          typename: "PlaylistResponseWrapper",
          playlist: SpotifySectionPlaylist(
            name: "Playlist $i",
            description: "Really super important description $i",
            format: "daily-mix",
            images: [
              const SpotifySectionItemImage(
                height: 1,
                width: 1,
                url: "https://dummyimage.com/100x100/cfcfcf/cfcfcf.jpg",
              ),
            ], owner: '', uri: '',
          ),
        ),
    ],
  );
  static final historyRecentlyPlayedTrack = HistoryTableData(
    id: 0,
    type: HistoryEntryType.track,
    createdAt: DateTime.now(),
    itemId: "1",
    data: sourceableTrack.toJson(),
  );
  
  static const historySummary = PlaybackHistorySummary(
    albums: 1,
    artists: 1,
    duration: Duration(seconds: 1),
    playlists: 1,
    tracks: 1,
    fees: 1,
  );
  
  static final historyRecentlyPlayedItems = List.generate(
    10,
    (index) => historyRecentlyPlayedTrack,
  );

  static final Category category = Category()
    ..href = "text"
    ..icons = [
      Image()
        ..url = "https://via.placeholder.com/150"
        ..height = 150
        ..width = 150
    ]
    ..id = "1"
    ..name = "category";

  // 添加通用用户实现
  static final baseUser = base_user.User(
    id: "1",
    name: "测试用户",
    email: "test@example.com",
    imageUrl: image.url,
    platform: "spotify",
  );

  // 修复 user 对象定义，使用正确的 Spotify User 类型和级联表示法
  static final followers = Followers()..total = 100;
  
  static final User user = User()
    ..id = "1"
    ..displayName = "测试用户"
    ..birthdate = "2000-01-01"
    ..country = Market.US
    ..email = "test@example.com"
    ..followers = followers
    ..href = "text"
    ..images = [image]
    ..type = "type"
    ..uri = "uri"
    ..product = "premium";

  static final TracksLink tracksLink = TracksLink()
    ..href = "text"
    ..total = 1;
}

// 删除类外部的 user 定义
// 这里只保留 _FakeTrack 和 SourcedTrackImpl 类
class _FakeTrack implements SourceableTrack {
  @override
  String get id => "fake_track_id";
  
  @override
  String get title => "A Track Name";
  
  @override
  String get artistName => "Wow artist Good!";
  
  @override
  String? get albumName => "A good album";
  
  @override
  Duration get duration => const Duration(milliseconds: 50000);
  
  @override
  String? get thumbnailUrl => FakeData.image.url;  // 修复重复定义并使用正确的图片URL
  
  @override
  String? get albumId => "1";
  
  @override
  String? get artistId => "1";
  @override
  String getSearchTerm() {
    return "$title - $artistName";
  }
  @override
  Map<String, dynamic> toMediaItem() {
    return {
      'id': id,
      'title': title,
      'artist': artistName,
      'album': albumName,
      'duration': duration.inMilliseconds,
      'artUri': thumbnailUrl,
    };
  }
  @override
  String getDisplayName() {
    return "$title - $artistName";
  }
  @override
  String getDescription() {
    return albumName != null ? "专辑: $albumName" : "";
  }
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artistName': artistName,
    'albumName': albumName,
    'duration': duration.inMilliseconds,
    'thumbnailUrl': thumbnailUrl,
    'albumId': albumId,
    'artistId': artistId,
  };
}

// 通用接口实现类
class SourcedTrackImpl implements SourceableTrack {
  final String _id;
  final String _title;
  final String _artistName;
  final String? _albumName;
  final Duration _duration;
  final String? _thumbnailUrl;
  final String? _albumId;
  final String? _artistId;

  const SourcedTrackImpl({
    required String id,
    required String title,
    required String artistName,
    String? albumName,
    required Duration duration,
    String? thumbnailUrl,
    String? albumId,
    String? artistId,
  })  : _id = id,
        _title = title,
        _artistName = artistName,
        _albumName = albumName,
        _duration = duration,
        _thumbnailUrl = thumbnailUrl,
        _albumId = albumId,
        _artistId = artistId;

  @override
  String get id => _id;
  
  @override
  String get title => _title;
  
  @override
  String get artistName => _artistName;
  
  @override
  String? get albumName => _albumName;
  
  @override
  Duration get duration => _duration;
  
  @override
  String? get thumbnailUrl => _thumbnailUrl;
  
  @override
  String? get albumId => _albumId;
  
  @override
  String? get artistId => _artistId;

  @override
  String getSearchTerm() => "$title - $artistName";

  @override
  String getDisplayName() => "$title - $artistName";

  @override
  String getDescription() => albumName != null ? "专辑: $albumName" : "";

  @override
  Map<String, dynamic> toMediaItem() => {
    'id': id,
    'title': title,
    'artist': artistName,
    'album': albumName,
    'duration': duration.inMilliseconds,
    'artUri': thumbnailUrl,
  };

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artistName': artistName,
    'albumName': albumName,
    'duration': duration.inMilliseconds,
    'thumbnailUrl': thumbnailUrl,
    'albumId': albumId,
    'artistId': artistId,
  };
}

