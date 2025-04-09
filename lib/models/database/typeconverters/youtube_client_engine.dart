part of '../database.dart';

class YoutubeClientEngineConverter extends TypeConverter<YoutubeClientEngine?, String?> {
  const YoutubeClientEngineConverter();

  YoutubeClientEngine? mapToDart(String? fromDb) {
    if (fromDb == null) return YoutubeClientEngine.youtubeExplode;
    return YoutubeClientEngine.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => YoutubeClientEngine.youtubeExplode,
    );
  }

  String? mapToSql(YoutubeClientEngine? value) {
    return value?.name;
  }
  
  // Add the required methods from TypeConverter
  @override
  YoutubeClientEngine? fromSql(String? fromDb) {
    return mapToDart(fromDb);
  }

  @override
  String? toSql(YoutubeClientEngine? value) {
    return mapToSql(value);
  }
}