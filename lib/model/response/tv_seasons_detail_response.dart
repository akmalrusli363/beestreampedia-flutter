import '../../utils/tv_show_utils.dart';
import '../tmdb_config_enums.dart';

class TvSeasonsDetail {
    String id;
    DateTime? airDate;
    List<Episode> episodes;
    String name;
    String overview;
    int tvSeasonsDetailId;
    String? posterPath;
    int seasonNumber;
    double? voteAverage;

    TvSeasonsDetail({
        required this.id,
        required this.airDate,
        required this.episodes,
        required this.name,
        required this.overview,
        required this.tvSeasonsDetailId,
        required this.posterPath,
        required this.seasonNumber,
        this.voteAverage,
    });

    factory TvSeasonsDetail.fromJson(Map<String, dynamic> json) => TvSeasonsDetail(
        id: json["_id"],
        airDate: (json["air_date"] != null) ? DateTime.parse(json["air_date"]) : null,
        episodes: List<Episode>.from(json["episodes"].map((x) => Episode.fromJson(x))),
        name: json["name"],
        overview: json["overview"],
        tvSeasonsDetailId: json["id"],
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
        voteAverage: (json["vote_average"] != null) ? json["vote_average"].toDouble() : null,
    );

    String getPosterUrl() {
        return getTmdbImageUrl(imageUrl: posterPath, width: ImageWidthOptions.w500);
    }
}

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

