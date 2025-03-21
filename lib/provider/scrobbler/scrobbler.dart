import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrobblenaut/scrobblenaut.dart';

import 'package:spotube/collections/env.dart';

import 'package:spotube/models/database/database.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/services/logger/logger.dart';
import 'package:spotube/services/base/sourceable_track.dart';

class ScrobblerNotifier extends AsyncNotifier<Scrobblenaut?> {
  final _scrobbleController = StreamController<SourceableTrack>.broadcast();
  StreamSubscription? _scrobbleSubscription;
  
  @override
  build() async {
    final database = ref.watch(databaseProvider);

    final loginInfo = await (database.select(database.scrobblerTable)
          ..where((t) => t.id.equals(0)))
        .getSingleOrNull();

    final subscription =
        database.select(database.scrobblerTable).watch().listen((event) async {
      try {
        if (event.isNotEmpty) {
          state = await AsyncValue.guard(
            () async => Scrobblenaut(
              lastFM: await LastFM.authenticateWithPasswordHash(
                apiKey: Env.lastFmApiKey,
                apiSecret: Env.lastFmApiSecret,
                username: event.first.username,
                passwordHash: event.first.passwordHash.value,
              ),
            ),
          );
        } else {
          state = const AsyncValue.data(null);
        }
      } catch (e, stack) {
        AppLogger.reportError(e, stack);
      }
    });

    _scrobbleSubscription?.cancel();
    _scrobbleSubscription = _scrobbleController.stream.listen((track) async {
      try {
        await state.asData?.value?.track.scrobble(
          artist: track.artistName,
          track: track.title,
          album: track.albumName ?? "",
          chosenByUser: true,
          duration: track.duration,
          timestamp: DateTime.now().toUtc(),
        );
      } catch (e, stackTrace) {
        AppLogger.reportError(e, stackTrace);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
      _scrobbleSubscription?.cancel();
      _scrobbleController.close();
    });

    if (loginInfo == null) {
      return null;
    }

    return Scrobblenaut(
      lastFM: await LastFM.authenticateWithPasswordHash(
        apiKey: Env.lastFmApiKey,
        apiSecret: Env.lastFmApiSecret,
        username: loginInfo.username,
        passwordHash: loginInfo.passwordHash.value,
      ),
    );
  }

  Future<void> login(
    String username,
    String password,
  ) async {
    final database = ref.read(databaseProvider);

    final lastFm = await LastFM.authenticate(
      apiKey: Env.lastFmApiKey,
      apiSecret: Env.lastFmApiSecret,
      username: username,
      password: password,
    );

    if (!lastFm.isAuth) throw Exception("Invalid credentials");

    await database.into(database.scrobblerTable).insert(
          ScrobblerTableCompanion.insert(
            id: const Value(0),
            username: username,
            passwordHash: DecryptedText(lastFm.passwordHash!),
          ),
        );
  }

  Future<void> logout() async {
    state = const AsyncValue.data(null);
    final database = ref.read(databaseProvider);
    await database.delete(database.scrobblerTable).go();
  }

  void scrobble(SourceableTrack track) {
    _scrobbleController.add(track);
  }

  Future<void> love(SourceableTrack track) async {
    await state.asData?.value?.track.love(
      artist: track.artistName,
      track: track.title,
    );
  }

  Future<void> unlove(SourceableTrack track) async {
    await state.asData?.value?.track.unLove(
      artist: track.artistName,
      track: track.title,
    );
  }
  // 删除这部分重复的代码
  /*
  final scrobblerSubscription =
      _scrobbleController.stream.listen((track) async {
    try {
      await state.asData?.value?.track.scrobble(
        artist: track.artistName,
        track: track.title,
        album: track.albumName ?? "",
        chosenByUser: true,
        duration: track.duration,
        timestamp: DateTime.now().toUtc(),
      );
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace);
    }
  });
  */
}

final scrobblerProvider =
    AsyncNotifierProvider<ScrobblerNotifier, Scrobblenaut?>(
  () => ScrobblerNotifier(),
);
