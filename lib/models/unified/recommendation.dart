
class RecommendationAttribute {
  final double? min;
  final double? target;
  final double? max;

  const RecommendationAttribute({
    this.min,
    this.target,
    this.max,
  });

  Map<String, double?> toJson() {
    return {
      'min': min,
      'target': target,
      'max': max,
    };
  }
}

class RecommendationSeeds {
  final List<String>? seedArtists;
  final List<String>? seedGenres;
  final List<String>? seedTracks;
  final int limit;
  final RecommendationAttribute? acousticness;
  final RecommendationAttribute? danceability;
  final RecommendationAttribute? energy;
  final RecommendationAttribute? instrumentalness;
  final RecommendationAttribute? key;
  final RecommendationAttribute? liveness;
  final RecommendationAttribute? loudness;
  final RecommendationAttribute? mode;
  final RecommendationAttribute? popularity;
  final RecommendationAttribute? speechiness;
  final RecommendationAttribute? tempo;
  final RecommendationAttribute? timeSignature;
  final RecommendationAttribute? valence;

  const RecommendationSeeds({
    this.seedArtists,
    this.seedGenres,
    this.seedTracks,
    this.limit = 20,
    this.acousticness,
    this.danceability,
    this.energy,
    this.instrumentalness,
    this.key,
    this.liveness,
    this.loudness,
    this.mode,
    this.popularity,
    this.speechiness,
    this.tempo,
    this.timeSignature,
    this.valence,
  });

  // 添加 copyWith 方法，避免每次修改属性时都需要穷举所有字段
  RecommendationSeeds copyWith({
    List<String>? seedArtists,
    List<String>? seedGenres,
    List<String>? seedTracks,
    int? limit,
    RecommendationAttribute? acousticness,
    RecommendationAttribute? danceability,
    RecommendationAttribute? energy,
    RecommendationAttribute? instrumentalness,
    RecommendationAttribute? key,
    RecommendationAttribute? liveness,
    RecommendationAttribute? loudness,
    RecommendationAttribute? mode,
    RecommendationAttribute? popularity,
    RecommendationAttribute? speechiness,
    RecommendationAttribute? tempo,
    RecommendationAttribute? timeSignature,
    RecommendationAttribute? valence,
  }) {
    return RecommendationSeeds(
      seedArtists: seedArtists ?? this.seedArtists,
      seedGenres: seedGenres ?? this.seedGenres,
      seedTracks: seedTracks ?? this.seedTracks,
      limit: limit ?? this.limit,
      acousticness: acousticness ?? this.acousticness,
      danceability: danceability ?? this.danceability,
      energy: energy ?? this.energy,
      instrumentalness: instrumentalness ?? this.instrumentalness,
      key: key ?? this.key,
      liveness: liveness ?? this.liveness,
      loudness: loudness ?? this.loudness,
      mode: mode ?? this.mode,
      popularity: popularity ?? this.popularity,
      speechiness: speechiness ?? this.speechiness,
      tempo: tempo ?? this.tempo,
      timeSignature: timeSignature ?? this.timeSignature,
      valence: valence ?? this.valence,
    );
  }
}