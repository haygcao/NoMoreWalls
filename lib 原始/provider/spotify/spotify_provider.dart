import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/collections/env.dart';

import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/utils/primitive_utils.dart';

final spotifyProvider = Provider<SpotifyApi>((ref) {
  final authState = ref.watch(spotifyAuthenticationProvider);
  final anonCred = PrimitiveUtils.getRandomElement(Env.spotifySecrets);

  if (authState.asData?.value == null) {
    return SpotifyApi(
      SpotifyApiCredentials(
        anonCred["clientId"],
        anonCred["clientSecret"],
      ),
    );
  }

  return SpotifyApi.withAccessToken(authState.asData!.value!.accessToken.value);
});
