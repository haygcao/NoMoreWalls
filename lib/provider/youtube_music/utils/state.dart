part of '../youtube_music.dart';

class YoutubeMusicState {
  final bool isAuthenticated;
  final YoutubeMusicUser? user;
  final YoutubeMusicLibrary? library;

  const YoutubeMusicState({
    required this.isAuthenticated,
    this.user,
    this.library,
  });
}