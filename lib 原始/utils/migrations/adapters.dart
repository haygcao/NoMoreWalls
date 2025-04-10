import 'package:hive/hive.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spotube/modules/settings/color_scheme_picker_dialog.dart';
import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/sourced_track/enums.dart';
import 'package:spotube/services/base/base_models.dart';
import 'package:spotube/services/base/playlist.dart'; // 添加 Playlist 导入
import 'package:spotube/services/base/album.dart'; // 添加 Album 导入


part 'adapters.g.dart';
part 'adapters.freezed.dart';

@HiveType(typeId: 2)
class SkipSegment {
  @HiveField(0)
  final int start;
  @HiveField(1)
  final int end;
  SkipSegment(this.start, this.end);

  static String version = 'v1';
  static final boxName = "oss.krtirtho.spotube.skip_segments.$version";
  static LazyBox get box => Hive.lazyBox(boxName);

  SkipSegment.fromJson(Map<String, dynamic> json)
      : start = json['start'],
        end = json['end'];

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
      };
}

@JsonEnum()
@HiveType(typeId: 5)
enum SourceType {
  @HiveField(0)
  youtube._("YouTube"),

  @HiveField(1)
  youtubeMusic._("YouTube Music"),

  @HiveField(2)
  jiosaavn._("JioSaavn");

  final String label;

  const SourceType._(this.label);
}
// 移除 @JsonSerializable() 注解
@HiveType(typeId: 6)
class SourceMatch {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sourceId;

  @HiveField(2)
  SourceType sourceType;

  @HiveField(3)
  DateTime createdAt;

  SourceMatch({
    required this.id,
    required this.sourceId,
    required this.sourceType,
    required this.createdAt,
  });
  // 手动实现 fromJson 方法
  factory SourceMatch.fromJson(Map<String, dynamic> json) {
    return SourceMatch(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      sourceType: SourceType.values.firstWhere(
        (e) => e.name == json['sourceType'],
        orElse: () => SourceType.youtube,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  // 手动实现 toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'sourceType': sourceType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  static String version = 'v1';
  static final boxName = "oss.krtirtho.spotube.source_matches.$version";
  static LazyBox<SourceMatch> get box => Hive.lazyBox<SourceMatch>(boxName);
}
@JsonSerializable()
class AuthenticationCredentials {
  String cookie;
  String accessToken;
  DateTime expiration;

  AuthenticationCredentials({
    required this.cookie,
    required this.accessToken,
    required this.expiration,
  });

  factory AuthenticationCredentials.fromJson(Map<String, dynamic> json) {
    return AuthenticationCredentials(
      cookie: json['cookie'] as String,
      accessToken: json['accessToken'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookie': cookie,
      'accessToken': accessToken,
      'expiration': expiration.toIso8601String(),
    };
  }
}

@JsonEnum()
enum LayoutMode {
  compact,
  extended,
  adaptive,
}

@JsonEnum()
enum CloseBehavior {
  minimizeToTray,
  close,
}

@JsonEnum()
enum AudioSource {
  youtube,
  piped,
  jiosaavn;

  String get label => name[0].toUpperCase() + name.substring(1);
}

@JsonEnum()
enum MusicCodec {
  m4a._("M4a (Best for downloaded music)"),
  weba._("WebA (Best for streamed music)\nDoesn't support audio metadata");

  final String label;
  const MusicCodec._(this.label);
}

@JsonEnum()
enum SearchMode {
  youtube._("YouTube"),
  youtubeMusic._("YouTube Music");

  final String label;

  const SearchMode._(this.label);

  factory SearchMode.fromString(String key) {
    return SearchMode.values.firstWhere((e) => e.name == key);
  }
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(SourceQualities.high) SourceQualities audioQuality,
    @Default(true) bool albumColorSync,
    @Default(false) bool amoledDarkTheme,
    @Default(true) bool checkUpdate,
    @Default(false) bool normalizeAudio,
    @Default(false) bool showSystemTrayIcon,
    @Default(false) bool skipNonMusic,
    @Default(false) bool systemTitleBar,
    @Default(CloseBehavior.close) CloseBehavior closeBehavior,
    @Default(SpotubeColor(0xFF2196F3, name: "Blue"))
    @JsonKey(
      fromJson: UserPreferences._accentColorSchemeFromJson,
      toJson: UserPreferences._accentColorSchemeToJson,
      readValue: UserPreferences._accentColorSchemeReadValue,
    )
    SpotubeColor accentColorScheme,
    @Default(LayoutMode.adaptive) LayoutMode layoutMode,
    @Default(Locale("system", "system"))
    @JsonKey(
      fromJson: UserPreferences._localeFromJson,
      toJson: UserPreferences._localeToJson,
      readValue: UserPreferences._localeReadValue,
    )
    Locale locale,
    // 使用字符串存储市场代码，而不是直接使用 Market 或 AppMarket 类型
    @Default("US")
    @JsonKey(
      fromJson: UserPreferences._marketFromJson,
      toJson: UserPreferences._marketToJson,
    )
    String market,
    @Default(SearchMode.youtube) SearchMode searchMode,
    @Default("") String downloadLocation,
    @Default([]) List<String> localLibraryLocation,
    @Default("https://pipedapi.kavin.rocks") String pipedInstance,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(AudioSource.youtube) AudioSource audioSource,
    @Default(SourceCodecs.weba) SourceCodecs streamMusicCodec,
    @Default(SourceCodecs.m4a) SourceCodecs downloadMusicCodec,
    @Default(true) bool discordPresence,
    @Default(true) bool endlessPlayback,
    @Default(false) bool enableConnect,
  }) = _UserPreferences;
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  
  factory UserPreferences.withDefaults() => UserPreferences.fromJson({});
  
  static SpotubeColor _accentColorSchemeFromJson(Map<String, dynamic> json) {
    return SpotubeColor.fromString(json["color"]);
  }
  
  static String _marketFromJson(Map<String, dynamic> json) {
    return json["market"] as String? ?? "US";
  }
  
  static Map<String, dynamic> _marketToJson(String market) {
    return {"market": market};
  }
  
  static Map<String, dynamic>? _accentColorSchemeReadValue(
      Map<dynamic, dynamic> json, String key) {
    if (json[key] is String) {
      return {"color": json[key]};
    }

    return json[key] as Map<String, dynamic>?;
  }
  
  static Map<String, dynamic> _accentColorSchemeToJson(SpotubeColor color) {
    return {"color": color.toString()};
  }
  
  static Locale _localeFromJson(Map<String, dynamic> json) {
    return Locale(json["languageCode"], json["countryCode"]);
  }
  
  static Map<String, dynamic> _localeToJson(Locale locale) {
    return {
      "languageCode": locale.languageCode,
      "countryCode": locale.countryCode,
    };
  }
  
  static Map<String, dynamic>? _localeReadValue(
      Map<dynamic, dynamic> json, String key) {
    if (json[key] is String) {
      final map = jsonDecode(json[key]);
      return {
        "languageCode": map["lc"],
        "countryCode": map["cc"],
      };
    }

    return json[key] as Map<String, dynamic>?;
  }
}

enum BlacklistedType {
  artist,
  track;

  static BlacklistedType fromName(String name) =>
      BlacklistedType.values.firstWhere((e) => e.name == name);
}

class BlacklistedElement {
  final String id;
  final String name;
  final BlacklistedType type;

  BlacklistedElement.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = BlacklistedType.fromName(json['type']);

  Map<String, dynamic> toJson() => {'id': id, 'type': type.name, 'name': name};
}
// 添加 PlaylistBase 的 JsonConverter
class PlaylistBaseConverter implements JsonConverter<PlaylistBase, Map<String, dynamic>> {
  const PlaylistBaseConverter();

  @override
  PlaylistBase fromJson(Map<String, dynamic> json) {
    // 使用类型转换确保返回类型兼容
    return Playlist.fromJson(json) as PlaylistBase;
  }

  @override
  Map<String, dynamic> toJson(PlaylistBase object) {
    return object.toJson();
  }
}

// 添加 AlbumBase 的 JsonConverter
class AlbumBaseConverter implements JsonConverter<AlbumBase, Map<String, dynamic>> {
  const AlbumBaseConverter();

  @override
  AlbumBase fromJson(Map<String, dynamic> json) {
    // 使用类型转换确保返回类型兼容
    return Album.fromJson(json) as AlbumBase;
  }

  @override
  Map<String, dynamic> toJson(AlbumBase object) {
    return object.toJson();
  }
}

// 修改 BaseTrack 的 JsonConverter
class BaseTrackConverter implements JsonConverter<BaseTrack, Map<String, dynamic>> {
  const BaseTrackConverter();

  @override
  BaseTrack fromJson(Map<String, dynamic> json) {
    // 简单返回一个匿名实现
    return _AnonymousTrack.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(BaseTrack object) {
    return object.toJson();
  }
}

// 添加一个匿名实现类
class _AnonymousTrack implements BaseTrack {
  final String _id;
  final String _title;
  final String? _artistName;
  final String? _albumName;
  final Duration? _duration;
  final Map<String, dynamic> _json;

  _AnonymousTrack({
    required String id,
    required String title,
    String? artistName,
    String? albumName,
    Duration? duration,
    required Map<String, dynamic> json,
  })  : _id = id,
        _title = title,
        _artistName = artistName,
        _albumName = albumName,
        _duration = duration,
        _json = json;

  factory _AnonymousTrack.fromJson(Map<String, dynamic> json) {
    return _AnonymousTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: json['artistName'] as String?,
      albumName: json['albumName'] as String?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      json: json,
    );
  }

  @override
  String get id => _id;

  @override
  String get title => _title;

  @override
  String? get artistName => _artistName;

  @override
  String? get albumName => _albumName;

  @override
  Duration? get duration => _duration;

  @override
  Map<String, dynamic> toJson() => _json;
}

@freezed
class PlaybackHistoryItem with _$PlaybackHistoryItem {
  factory PlaybackHistoryItem.playlist({
    required DateTime date,
    @PlaylistBaseConverter() required PlaylistBase playlist,
  }) = PlaybackHistoryPlaylist;

  factory PlaybackHistoryItem.album({
    required DateTime date,
    @AlbumBaseConverter() required AlbumBase album,
  }) = PlaybackHistoryAlbum;
  
  factory PlaybackHistoryItem.track({
    required DateTime date,
    @BaseTrackConverter() required BaseTrack track,  // 添加 JsonConverter 注解
  }) = PlaybackHistoryTrack;
  
  factory PlaybackHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PlaybackHistoryItemFromJson(json);
}

class PlaybackHistoryState {
  final List<PlaybackHistoryItem> items;
  const PlaybackHistoryState({this.items = const []});

  factory PlaybackHistoryState.fromJson(Map<String, dynamic> json) {
    return PlaybackHistoryState(
      items: json["items"]
              ?.map(
                (json) => PlaybackHistoryItem.fromJson(json),
              )
              .toList()
              .cast<PlaybackHistoryItem>() ??
          <PlaybackHistoryItem>[],
    );
  }
}

class ScrobblerState {
  final String username;
  final String passwordHash;

  ScrobblerState({
    required this.username,
    required this.passwordHash,
  });

  factory ScrobblerState.fromJson(Map<String, dynamic> json) {
    return ScrobblerState(
      username: json["username"],
      passwordHash: json["passwordHash"],
    );
  }
}