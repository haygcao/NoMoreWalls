import 'dart:async';

import 'package:flutter/material.dart' hide Page;
// 移除 Spotify 导入
// import 'package:spotify/spotify.dart';
import 'package:spotube/services/base/sourceable_track.dart';
import 'package:spotube/services/base/collection.dart';

class PaginationProps {
  final bool hasNextPage;
  final bool isLoading;
  final VoidCallback onFetchMore;
  final Future<void> Function() onRefresh;
  final Future<List<SourceableTrack>> Function() onFetchAll;

  const PaginationProps({
    required this.hasNextPage,
    required this.isLoading,
    required this.onFetchMore,
    required this.onFetchAll,
    required this.onRefresh,
  });

  @override
  operator ==(Object other) {
    return other is PaginationProps &&
        other.hasNextPage == hasNextPage &&
        other.isLoading == isLoading &&
        other.onFetchMore == onFetchMore &&
        other.onFetchAll == onFetchAll &&
        other.onRefresh == onRefresh;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      hasNextPage.hashCode ^
      isLoading.hashCode ^
      onFetchMore.hashCode ^
      onFetchAll.hashCode ^
      onRefresh.hashCode;
}

class InheritedTrackView extends InheritedWidget {
  final Collection collection;
  final String title;
  final String? description;
  final String image;
  final String routePath;
  final List<SourceableTrack> tracks;
  final PaginationProps pagination;
  final bool isLiked;
  final String shareUrl;

  // events
  final FutureOr<bool?> Function()? onHeart; // if null heart button will hidden

  const InheritedTrackView({
    super.key,
    required super.child,
    required this.collection,
    required this.title,
    this.description,
    required this.image,
    required this.tracks,
    required this.pagination,
    required this.routePath,
    required this.shareUrl,
    this.isLiked = false,
    this.onHeart,
  });

  String get collectionId => collection.id;

  @override
  bool updateShouldNotify(InheritedTrackView oldWidget) {
    return oldWidget.title != title ||
        oldWidget.description != description ||
        oldWidget.image != image ||
        oldWidget.tracks != tracks ||
        oldWidget.pagination != pagination ||
        oldWidget.isLiked != isLiked ||
        oldWidget.onHeart != onHeart ||
        oldWidget.shareUrl != shareUrl ||
        oldWidget.routePath != routePath ||
        oldWidget.collection != collection ||
        oldWidget.child != child;
  }

  static InheritedTrackView of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<InheritedTrackView>();
    if (widget == null) {
      throw Exception(
        'InheritedTrackView not found. Make sure to wrap [TrackView] with [InheritedTrackView]',
      );
    }
    return widget;
  }
}
