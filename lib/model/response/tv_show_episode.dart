import '../../utils/tv_show_utils.dart';
import '../tmdb_config_enums.dart';

class Episode {
  DateTime? airDate;
  int episodeNumber;
  String episodeType;
  int id;
  String name;
  String overview;
  int runtime;
  int seasonNumber;
  int showId;
  String? stillPath;
  double? voteAverage;
  int? voteCount;

  Episode({
    required this.airDate,
    required this.episodeNumber,
    required this.episodeType,
    required this.id,
    required this.name,
    required this.overview,
    required this.runtime,
    required this.seasonNumber,
    required this.showId,
    required this.stillPath,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    airDate: parseDateOrNull(json["air_date"]),
    episodeNumber: json["episode_number"],
    episodeType: json["episode_type"],
    id: json["id"],
    name: json["name"],
    overview: json["overview"],
    runtime: json["runtime"] ?? 0,
    seasonNumber: json["season_number"],
    showId: json["show_id"],
    stillPath: json["still_path"] ?? "",
    voteAverage: json["vote_average"],
    voteCount: json["vote_count"],
  );

  String getThumbnailUrl() {
    return getTmdbImageUrl(imageUrl: stillPath, width: ImageWidthOptions.w500);
  }
}