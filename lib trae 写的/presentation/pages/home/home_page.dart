import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search page
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          HomeHeader(),
          SizedBox(height: 24),
          FeaturedPlaylists(),
          SizedBox(height: 24),
          RecentTracks(),
          SizedBox(height: 24),
          RecommendedArtists(),
        ],
      ),
    );
  }
}

// Placeholder widgets that will be implemented in separate files
class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Welcome to Spotube',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FeaturedPlaylists extends StatelessWidget {
  const FeaturedPlaylists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Featured Playlists',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Placeholder for playlist grid
        Center(child: Text('Featured playlists will appear here')),
      ],
    );
  }
}

class RecentTracks extends StatelessWidget {
  const RecentTracks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Recently Played',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Placeholder for recent tracks list
        Center(child: Text('Recent tracks will appear here')),
      ],
    );
  }
}

class RecommendedArtists extends StatelessWidget {
  const RecommendedArtists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Recommended Artists',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Placeholder for artists grid
        Center(child: Text('Recommended artists will appear here')),
      ],
    );
  }
}
