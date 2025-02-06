import 'package:beestream_pedia/model/response/tv_show_episode.dart';

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
