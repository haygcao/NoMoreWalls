part of 'connect.dart';

class WebSocketLoadEventData {
  final List<SourceableTrack> tracks;
  final String? collectionId;
  final int? initialIndex;
  final Map<String, dynamic>? collection;  // 添加 collection 字段

  WebSocketLoadEventData({
    required this.tracks,
    this.collectionId,
    this.initialIndex,
    this.collection,  // 添加到构造函数
  });

  Map<String, dynamic> toJson() => {
    'tracks': tracks.map((e) => e.toJson()).toList(),
    'collectionId': collectionId,
    'initialIndex': initialIndex,
    if (collection != null) 'collection': collection,  // 添加到 toJson
  };

  factory WebSocketLoadEventData.fromJson(
    Map<String, dynamic> json,
    SourceableTrack Function(Map<String, dynamic>) trackFromJson,
  ) {
    return WebSocketLoadEventData(
      tracks: (json['tracks'] as List)
          .map((track) => trackFromJson(track as Map<String, dynamic>))
          .toList(),
      collectionId: json['collectionId'] as String?,
      initialIndex: json['initialIndex'] as int?,
      collection: json['collection'] as Map<String, dynamic>?,  // 从 JSON 解析
    );
  }
  // 添加 album 构造函数
  factory WebSocketLoadEventData.album({
    required List<SourceableTrack> tracks,
    required AlbumBase collection,
    int? initialIndex,
  }) {
    return WebSocketLoadEventData(
      tracks: tracks,
      collectionId: collection.id,
      collection: collection.toJson(),
      initialIndex: initialIndex,
    );
  }
  
  // 添加 playlist 构造函数
  factory WebSocketLoadEventData.playlist({
    required List<SourceableTrack> tracks,
    required PlaylistCollection collection,
    int? initialIndex,
  }) {
    return WebSocketLoadEventData(
      tracks: tracks,
      collectionId: collection.id,
      collection: collection.toJson(),
      initialIndex: initialIndex,
    );
  }
}

class WebSocketLoadEvent extends WebSocketEvent<WebSocketLoadEventData> {
  WebSocketLoadEvent(WebSocketLoadEventData data) : super(WsEvent.load, data);

  factory WebSocketLoadEvent.fromJson(
    Map<String, dynamic> json,
    SourceableTrack Function(Map<String, dynamic>) trackFromJson,
  ) {
    return WebSocketLoadEvent(
      WebSocketLoadEventData.fromJson(
        json['data'] as Map<String, dynamic>,
        trackFromJson,
      ),
    );
  }
}
