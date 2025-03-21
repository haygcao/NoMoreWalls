library youtube_music;


import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/models/youtube_music/album.dart';
import 'package:spotube/models/youtube_music/section.dart';
import 'package:spotube/models/youtube_music/track.dart';
import 'package:spotube/models/youtube_music/user.dart';
import 'package:spotube/models/youtube_music/channel.dart';
import 'package:spotube/models/youtube_music/playlist.dart';
import 'package:spotube/models/youtube_music/library.dart';
import 'package:spotube/models/youtube_music/search.dart';
import 'package:spotube/provider/lyrics/base_lyrics_provider.dart';
import 'package:spotube/provider/youtube_music/youtube_music_provider.dart';
import 'package:spotube/services/base/base_track.dart';

import 'package:spotube/provider/lyrics/lyrics_providers.dart';
import 'package:spotube/provider/lyrics/providers/lrclib_lyrics.dart';
import 'package:spotube/provider/lyrics/providers/petit_lyrics.dart';
import 'package:spotube/provider/lyrics/providers/spotify_lyrics.dart';
import 'package:spotube/provider/lyrics/providers/youtube_lyrics.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/provider/youtube_music/auth_provider.dart';
import 'package:spotube/services/logger/logger.dart';

import 'package:spotube/services/youtube_music/youtube_music_service.dart';
import 'package:spotube/models/youtube_music/category.dart';
// 在 part 声明部分添加
part 'user/liked_tracks.dart';
part 'album/album.dart';

part 'artist/artist.dart';


part 'category/categories.dart';
part 'playlist/playlist.dart';
part 'lyrics/synced.dart';
part 'lyrics/youtube_lyrics_notifier.dart';
part 'search/search.dart';
part 'user/me.dart';
part 'user/library.dart';
part 'home/home.dart';
part 'utils/provider.dart';
part 'utils/state.dart';


