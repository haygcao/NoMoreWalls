import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'package:spotube/models/connect/connect.dart';

import 'package:spotube/provider/history/history.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/provider/volume_provider.dart';
import 'package:spotube/services/audio_player/audio_player.dart';

import 'package:spotube/services/logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:spotube/services/track_factory.dart';
import 'package:spotube/services/base/collection.dart';  // 添加这个导入

// 添加一个 Collection 的实现类
class _WebSocketCollection implements Collection {
  final Map<String, dynamic> _data;
  
  _WebSocketCollection(this._data);
  
  @override
  String get id => _data['id'] as String;
  
  @override
  String get name => _data['name'] as String;
  
  @override
  String? get description => _data['description'] as String?;
  
  @override
  String? get imageUrl => _data['imageUrl'] as String?;
  
  @override
  String get uri => _data['uri'] as String;
  
  @override
  String get type => _data['type'] as String;
  
  @override
  Map<String, dynamic> toJson() => _data;
}

extension _WebsocketSinkExts on WebSocketSink {
  void addEvent(WebSocketEvent event) {
    add(event.toJson());
  }
}

class ServerConnectRoutes {
  final Ref ref;
  final StreamController<String> _connectClientStreamController;
  final List<StreamSubscription> subscriptions;
  ServerConnectRoutes(this.ref)
      : _connectClientStreamController = StreamController<String>.broadcast(),
        subscriptions = [] {
    ref.onDispose(() {
      _connectClientStreamController.close();
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    });
  }

  AudioPlayerNotifier get audioPlayerNotifier =>
      ref.read(audioPlayerProvider.notifier);
  PlaybackHistoryActions get historyNotifier =>
      ref.read(playbackHistoryActionsProvider);
  Stream<String> get connectClientStream =>
      _connectClientStreamController.stream;

  FutureOr<Response> websocket(Request req) {
    return webSocketHandler(
      (
        WebSocketChannel channel,
        String? protocol,
      ) async {
        final context =
            (req.context["shelf.io.connection_info"] as HttpConnectionInfo?);
        final origin = "${context?.remoteAddress.host}:${context?.remotePort}";
        _connectClientStreamController.add(origin);

        ref.listen(
          audioPlayerProvider,
          (previous, next) {
            channel.sink.addEvent(WebSocketQueueEvent(next));
          },
          fireImmediately: true,
        );

        // because audioPlayer events doesn't fireImmediately
        channel.sink.addEvent(WebSocketPlayingEvent(audioPlayer.isPlaying));
        channel.sink.addEvent(
          WebSocketPositionEvent(audioPlayer.position),
        );
        channel.sink.addEvent(
          WebSocketDurationEvent(audioPlayer.duration),
        );
        channel.sink.addEvent(WebSocketShuffleEvent(audioPlayer.isShuffled));
        channel.sink.addEvent(WebSocketLoopEvent(audioPlayer.loopMode));
        channel.sink.addEvent(WebSocketVolumeEvent(audioPlayer.volume));

        subscriptions.addAll([
          audioPlayer.positionStream.listen(
            (position) {
              channel.sink.addEvent(WebSocketPositionEvent(position));
            },
          ),
          audioPlayer.playingStream.listen(
            (playing) {
              channel.sink.addEvent(WebSocketPlayingEvent(playing));
            },
          ),
          audioPlayer.durationStream.listen(
            (duration) {
              channel.sink.addEvent(WebSocketDurationEvent(duration));
            },
          ),
          audioPlayer.shuffledStream.listen(
            (shuffled) {
              channel.sink.addEvent(WebSocketShuffleEvent(shuffled));
            },
          ),
          audioPlayer.loopModeStream.listen(
            (loopMode) {
              channel.sink.addEvent(WebSocketLoopEvent(loopMode));
            },
          ),
          audioPlayer.volumeStream.listen(
            (volume) {
              channel.sink.addEvent(WebSocketVolumeEvent(volume));
            },
          ),
          channel.stream.listen(
            (message) {
              try {
                final event = WebSocketEvent.fromJson(
                  jsonDecode(message),
                  (data) => data,
                );
                // 在 onLoad 处理部分修改代码
                event.onLoad(
                  (event) async {
                    await audioPlayerNotifier.load(
                      event.data.tracks,
                      autoPlay: true,
                      initialIndex: event.data.initialIndex ?? 0,
                    );
                    
                    if (event.data.collectionId == null) return;
                    audioPlayerNotifier.addCollection(event.data.collectionId!);
                    
                    // 使用统一的历史记录方法
                    if (event.data.collection != null) {
                      final collection = _WebSocketCollection(event.data.collection!);
                      historyNotifier.addCollection(collection);
                    }
                  },
                  TrackFactory.createFromJson  // 添加第二个参数
                );
                event.onPause((event) async {
                  await audioPlayer.pause();
                });

                event.onResume((event) async {
                  await audioPlayer.resume();
                });

                event.onStop((event) async {
                  await audioPlayer.stop();
                });

                event.onNext((event) async {
                  await audioPlayer.skipToNext();
                });

                event.onPrevious((event) async {
                  await audioPlayer.skipToPrevious();
                });

                event.onJump((event) async {
                  await audioPlayer.jumpTo(event.data);
                });

                event.onSeek((event) async {
                  await audioPlayer.seek(event.data);
                });

                event.onShuffle((event) async {
                  await audioPlayer.setShuffle(event.data);
                });

                event.onLoop((event) async {
                  await audioPlayer.setLoopMode(event.data);
                });
                // 使用 SourceableTrack 替代 Track
                event.onAddTrack(
                  (event) async {
                    await audioPlayerNotifier.addTrack(event.data);
                  },
                  TrackFactory.createFromJson  // 使用工厂类的静态方法作为第二个参数
                );
                event.onRemoveTrack((event) async {
                  await audioPlayerNotifier.removeTrack(event.data);
                });

                event.onReorder((event) async {
                  await audioPlayerNotifier.moveTrack(
                    event.data.oldIndex,
                    event.data.newIndex,
                  );
                });

                event.onVolume((event) async {
                  ref.read(volumeProvider.notifier).setVolume(event.data);
                });
              } catch (e, stackTrace) {
                AppLogger.reportError(e, stackTrace);
                channel.sink.addEvent(WebSocketErrorEvent(e.toString()));
              }
            },
            onDone: () {
              AppLogger.log.i('Connection closed');
            },
          ),
        ]);
      },
    )(req);
  }
}

final serverConnectRoutesProvider = Provider((ref) => ServerConnectRoutes(ref));
