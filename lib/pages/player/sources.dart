
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/modules/player/sibling_tracks_sheet.dart';

@RoutePage()
class PlayerTrackSourcesPage extends StatelessWidget {
  const PlayerTrackSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SiblingTracksSheet(floating: false),
    );
  }
}