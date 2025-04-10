import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/provider/spotify/spotify_provider.dart';
import 'package:spotube/services/custom_spotify_endpoints/spotify_endpoints.dart';

final customSpotifyEndpointProvider = Provider<CustomSpotifyEndpoints>((ref) {
  ref.watch(spotifyProvider);
  final auth = ref.watch(spotifyAuthenticationProvider);
  return CustomSpotifyEndpoints(auth.asData?.value?.accessToken.value ?? "");
});
