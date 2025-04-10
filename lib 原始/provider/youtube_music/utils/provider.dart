part of '../youtube_music.dart';

final youtubeMusicStateProvider = Provider<YoutubeMusicState>((ref) {
  final auth = ref.watch(youtubeMusicAuthProvider);
  final user = ref.watch(youtubeMusicUserProvider);
  final library = ref.watch(youtubeMusicUserLibraryProvider);

  return YoutubeMusicState(
    isAuthenticated: auth.hasValue && auth.value != null,
    user: user.value,
    library: library.value,
  );
});