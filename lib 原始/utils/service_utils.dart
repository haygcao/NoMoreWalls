import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spotube/collections/env.dart';
import 'package:spotube/provider/spotify/utils/sort_by.dart';

import 'package:spotube/modules/root/update_dialog.dart';
import 'package:spotube/provider/database/database.dart';
import 'package:spotube/services/base/base_track.dart';
import 'package:spotube/services/base/media_base.dart';
import 'package:spotube/services/dio/dio.dart';
import 'package:spotube/services/logger/logger.dart';
import 'package:version/version.dart';
// ... 其他导入

part 'service_utils/media_utils.dart';
part 'service_utils/navigation_utils.dart';
part 'service_utils/text_utils.dart';
part 'service_utils/update_utils.dart';

abstract class ServiceUtils {
  // MediaUtils 方法
  static List<T> sortTracks<T extends BaseTrack>(List<T> tracks, SortBy sortBy) {
    return MediaUtils.sortTracks(tracks, sortBy);
  }
  
  static DateTime parseAlbumDate(String? releaseDate, String? precision) {
    return MediaUtils.parseAlbumDate(releaseDate, precision);
  }
  
  static List<T> sortMediaItems<T extends MediaBase>(List<T> items, SortBy sortBy) {
    return MediaUtils.sortMediaItems(items, sortBy);
  }
  
  static Future<Uint8List?> downloadImage(String url) {
    return MediaUtils.downloadImage(url);
  }
  
  // TextUtils 方法
  static bool onlyContainsEnglish(String text) {
    return TextUtils.onlyContainsEnglish(text);
  }
  
  static String clearArtistsOfTitle(String title, List<String> artists) {
    return TextUtils.clearArtistsOfTitle(title, artists);
  }
  
  static String getTitle(String title, {List<String> artists = const [], bool onlyCleanArtist = false}) {
    return TextUtils.getTitle(title, artists: artists, onlyCleanArtist: onlyCleanArtist);
  }
  
  // NavigationUtils 方法
  static void navigate(BuildContext context, String location, {Object? extra}) {
    NavigationUtils.navigate(context, location, extra: extra);
  }
  
  static void navigateNamed(BuildContext context, String name, {
    Object? extra,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    NavigationUtils.navigateNamed(
      context, 
      name, 
      extra: extra, 
      pathParameters: pathParameters, 
      queryParameters: queryParameters
    );
  }
  
  static void push(BuildContext context, String location, {Object? extra}) {
    NavigationUtils.push(context, location, extra: extra);
  }
  
  static void pushNamed(BuildContext context, String name, {
    Object? extra,
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) {
    NavigationUtils.pushNamed(
      context, 
      name, 
      extra: extra, 
      pathParameters: pathParameters, 
      queryParameters: queryParameters
    );
  }
  
  // UpdateUtils 方法
  static Future<void> checkForUpdates(BuildContext context, WidgetRef ref) {
    return UpdateUtils.checkForUpdates(context, ref);
  }
}