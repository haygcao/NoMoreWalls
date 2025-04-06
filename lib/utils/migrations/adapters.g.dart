// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adapters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkipSegmentAdapter extends TypeAdapter<SkipSegment> {
  @override
  final int typeId = 2;

  @override
  SkipSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkipSegment(
      fields[0] as int,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SkipSegment obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkipSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SourceMatchAdapter extends TypeAdapter<SourceMatch> {
  @override
  final int typeId = 6;

  @override
  SourceMatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SourceMatch(
      id: fields[0] as String,
      sourceId: fields[1] as String,
      sourceType: fields[2] as SourceType,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SourceMatch obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceId)
      ..writeByte(2)
      ..write(obj.sourceType)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceMatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SourceTypeAdapter extends TypeAdapter<SourceType> {
  @override
  final int typeId = 5;

  @override
  SourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SourceType.youtube;
      case 1:
        return SourceType.youtubeMusic;
      case 2:
        return SourceType.jiosaavn;
      default:
        return SourceType.youtube;
    }
  }

  @override
  void write(BinaryWriter writer, SourceType obj) {
    switch (obj) {
      case SourceType.youtube:
        writer.writeByte(0);
        break;
      case SourceType.youtubeMusic:
        writer.writeByte(1);
        break;
      case SourceType.jiosaavn:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticationCredentials _$AuthenticationCredentialsFromJson(Map json) =>
    AuthenticationCredentials(
      cookie: json['cookie'] as String,
      accessToken: json['accessToken'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
    );

Map<String, dynamic> _$AuthenticationCredentialsToJson(
        AuthenticationCredentials instance) =>
    <String, dynamic>{
      'cookie': instance.cookie,
      'accessToken': instance.accessToken,
      'expiration': instance.expiration.toIso8601String(),
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(Map json) =>
    _$UserPreferencesImpl(
      audioQuality:
          $enumDecodeNullable(_$SourceQualitiesEnumMap, json['audioQuality']) ??
              SourceQualities.high,
      albumColorSync: json['albumColorSync'] as bool? ?? true,
      amoledDarkTheme: json['amoledDarkTheme'] as bool? ?? false,
      checkUpdate: json['checkUpdate'] as bool? ?? true,
      normalizeAudio: json['normalizeAudio'] as bool? ?? false,
      showSystemTrayIcon: json['showSystemTrayIcon'] as bool? ?? false,
      skipNonMusic: json['skipNonMusic'] as bool? ?? false,
      systemTitleBar: json['systemTitleBar'] as bool? ?? false,
      closeBehavior:
          $enumDecodeNullable(_$CloseBehaviorEnumMap, json['closeBehavior']) ??
              CloseBehavior.close,
      accentColorScheme: UserPreferences._accentColorSchemeReadValue(
                  json, 'accentColorScheme') ==
              null
          ? const SpotubeColor(0xFF2196F3, name: "Blue")
          : UserPreferences._accentColorSchemeFromJson(
              UserPreferences._accentColorSchemeReadValue(
                  json, 'accentColorScheme') as Map<String, dynamic>),
      layoutMode:
          $enumDecodeNullable(_$LayoutModeEnumMap, json['layoutMode']) ??
              LayoutMode.adaptive,
      locale: UserPreferences._localeReadValue(json, 'locale') == null
          ? const Locale("system", "system")
          : UserPreferences._localeFromJson(
              UserPreferences._localeReadValue(json, 'locale')
                  as Map<String, dynamic>),
      market: json['market'] == null
          ? "US"
          : UserPreferences._marketFromJson(
              json['market'] as Map<String, dynamic>),
      searchMode:
          $enumDecodeNullable(_$SearchModeEnumMap, json['searchMode']) ??
              SearchMode.youtube,
      downloadLocation: json['downloadLocation'] as String? ?? "",
      localLibraryLocation: (json['localLibraryLocation'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pipedInstance:
          json['pipedInstance'] as String? ?? "https://pipedapi.kavin.rocks",
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      audioSource:
          $enumDecodeNullable(_$AudioSourceEnumMap, json['audioSource']) ??
              AudioSource.youtube,
      streamMusicCodec: $enumDecodeNullable(
              _$SourceCodecsEnumMap, json['streamMusicCodec']) ??
          SourceCodecs.weba,
      downloadMusicCodec: $enumDecodeNullable(
              _$SourceCodecsEnumMap, json['downloadMusicCodec']) ??
          SourceCodecs.m4a,
      discordPresence: json['discordPresence'] as bool? ?? true,
      endlessPlayback: json['endlessPlayback'] as bool? ?? true,
      enableConnect: json['enableConnect'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'audioQuality': _$SourceQualitiesEnumMap[instance.audioQuality]!,
      'albumColorSync': instance.albumColorSync,
      'amoledDarkTheme': instance.amoledDarkTheme,
      'checkUpdate': instance.checkUpdate,
      'normalizeAudio': instance.normalizeAudio,
      'showSystemTrayIcon': instance.showSystemTrayIcon,
      'skipNonMusic': instance.skipNonMusic,
      'systemTitleBar': instance.systemTitleBar,
      'closeBehavior': _$CloseBehaviorEnumMap[instance.closeBehavior]!,
      'accentColorScheme':
          UserPreferences._accentColorSchemeToJson(instance.accentColorScheme),
      'layoutMode': _$LayoutModeEnumMap[instance.layoutMode]!,
      'locale': UserPreferences._localeToJson(instance.locale),
      'market': UserPreferences._marketToJson(instance.market),
      'searchMode': _$SearchModeEnumMap[instance.searchMode]!,
      'downloadLocation': instance.downloadLocation,
      'localLibraryLocation': instance.localLibraryLocation,
      'pipedInstance': instance.pipedInstance,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'audioSource': _$AudioSourceEnumMap[instance.audioSource]!,
      'streamMusicCodec': _$SourceCodecsEnumMap[instance.streamMusicCodec]!,
      'downloadMusicCodec': _$SourceCodecsEnumMap[instance.downloadMusicCodec]!,
      'discordPresence': instance.discordPresence,
      'endlessPlayback': instance.endlessPlayback,
      'enableConnect': instance.enableConnect,
    };

const _$SourceQualitiesEnumMap = {
  SourceQualities.high: 'high',
  SourceQualities.medium: 'medium',
  SourceQualities.low: 'low',
};

const _$CloseBehaviorEnumMap = {
  CloseBehavior.minimizeToTray: 'minimizeToTray',
  CloseBehavior.close: 'close',
};

const _$LayoutModeEnumMap = {
  LayoutMode.compact: 'compact',
  LayoutMode.extended: 'extended',
  LayoutMode.adaptive: 'adaptive',
};

const _$SearchModeEnumMap = {
  SearchMode.youtube: 'youtube',
  SearchMode.youtubeMusic: 'youtubeMusic',
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$AudioSourceEnumMap = {
  AudioSource.youtube: 'youtube',
  AudioSource.piped: 'piped',
  AudioSource.jiosaavn: 'jiosaavn',
};

const _$SourceCodecsEnumMap = {
  SourceCodecs.m4a: 'm4a',
  SourceCodecs.weba: 'weba',
};

_$PlaybackHistoryPlaylistImpl _$$PlaybackHistoryPlaylistImplFromJson(
        Map json) =>
    _$PlaybackHistoryPlaylistImpl(
      date: DateTime.parse(json['date'] as String),
      playlist: const PlaylistBaseConverter()
          .fromJson(json['playlist'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PlaybackHistoryPlaylistImplToJson(
        _$PlaybackHistoryPlaylistImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'playlist': const PlaylistBaseConverter().toJson(instance.playlist),
      'runtimeType': instance.$type,
    };

_$PlaybackHistoryAlbumImpl _$$PlaybackHistoryAlbumImplFromJson(Map json) =>
    _$PlaybackHistoryAlbumImpl(
      date: DateTime.parse(json['date'] as String),
      album: const AlbumBaseConverter()
          .fromJson(json['album'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PlaybackHistoryAlbumImplToJson(
        _$PlaybackHistoryAlbumImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'album': const AlbumBaseConverter().toJson(instance.album),
      'runtimeType': instance.$type,
    };

_$PlaybackHistoryTrackImpl _$$PlaybackHistoryTrackImplFromJson(Map json) =>
    _$PlaybackHistoryTrackImpl(
      date: DateTime.parse(json['date'] as String),
      track: const BaseTrackConverter()
          .fromJson(json['track'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PlaybackHistoryTrackImplToJson(
        _$PlaybackHistoryTrackImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'track': const BaseTrackConverter().toJson(instance.track),
      'runtimeType': instance.$type,
    };
