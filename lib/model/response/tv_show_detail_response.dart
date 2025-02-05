import '../../utils/tv_show_utils.dart';
import '../tmdb_config_enums.dart';

class TvShowDetail {
  bool? adult;
  String? backdropPath;
  late List<CreatedBy> createdBy = [];
  DateTime? firstAirDate;
  late List<Genres> genres = [];
  String? homepage;
  late final int id;
  bool? inProduction;
  late List<String> languages = [];
  DateTime? lastAirDate;
  LastEpisodeToAir? lastEpisodeToAir;
  late final String name;
  NextEpisodeToAir? nextEpisodeToAir;
  late List<Networks> networks;
  int? numberOfEpisodes;
  int? numberOfSeasons;
  late List<String> originCountry = [];
  String? originalLanguage;
  late final String originalName;
  late final String overview;
  double? popularity;
  String? posterPath;
  late List<ProductionCompanies> productionCompanies = [];
  late List<ProductionCountries> productionCountries = [];
  late List<TvShowSeason> seasons = [];
  late List<SpokenLanguages> spokenLanguages = [];
  String? status;
  String? tagline;
  String? type;
  double? voteAverage;
  int? voteCount;

  TvShowDetail(
      {this.adult,
        this.backdropPath,
        required this.createdBy,
        this.firstAirDate,
        required this.genres,
        this.homepage,
        required this.id,
        this.inProduction,
        required this.languages,
        this.lastAirDate,
        this.lastEpisodeToAir,
        required this.name,
        this.nextEpisodeToAir,
        required this.networks,
        this.numberOfEpisodes,
        this.numberOfSeasons,
        required this.originCountry,
        this.originalLanguage,
        required this.originalName,
        required this.overview,
        this.popularity,
        this.posterPath,
        required this.productionCompanies,
        required this.productionCountries,
        required this.seasons,
        required this.spokenLanguages,
        this.status,
        this.tagline,
        this.type,
        this.voteAverage,
        this.voteCount});

  String getPosterUrl() {
    return getTmdbImageUrl(imageUrl: posterPath, width: ImageWidthOptions.w500);
  }

  String getBackdropUrl() {
    return getTmdbImageUrl(imageUrl: backdropPath);
  }

  String getFullName() {
    return (name == originalName) ? name : "$name - ($originalName)";
  }

  TvShowDetail.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    createdBy = <CreatedBy>[];
    if (json['created_by'] != null) {
      json['created_by'].forEach((v) {
        createdBy.add(CreatedBy.fromJson(v));
      });
    }
    firstAirDate = parseDateOrNull(json["first_air_date"]);
    genres = <Genres>[];
    if (json['genres'] != null) {
      json['genres'].forEach((v) {
        genres.add(Genres.fromJson(v));
      });
    }
    homepage = json['homepage'];
    id = json['id'];
    inProduction = json['in_production'];
    languages = json['languages'].cast<String>();
    lastAirDate = parseDateOrNull(json["last_air_date"]);
    lastEpisodeToAir = json['last_episode_to_air'] != null
        ? LastEpisodeToAir.fromJson(json['last_episode_to_air'])
        : null;
    name = json['name'];
    nextEpisodeToAir = json['next_episode_to_air'] != null
        ? NextEpisodeToAir.fromJson(json['next_episode_to_air'])
        : null;
    networks = <Networks>[];
    if (json['networks'] != null) {
      json['networks'].forEach((v) {
        networks.add(Networks.fromJson(v));
      });
    }
    numberOfEpisodes = json['number_of_episodes'];
    numberOfSeasons = json['number_of_seasons'];
    originCountry = json['origin_country'].cast<String>();
    originalLanguage = json['original_language'];
    originalName = json['original_name'];
    overview = json['overview'];
    popularity = json['popularity'];
    posterPath = json['poster_path'];
    productionCompanies = <ProductionCompanies>[];
    if (json['production_companies'] != null) {
      json['production_companies'].forEach((v) {
        productionCompanies.add(ProductionCompanies.fromJson(v));
      });
    }
    productionCountries = <ProductionCountries>[];
    if (json['production_countries'] != null) {
      json['production_countries'].forEach((v) {
        productionCountries.add(ProductionCountries.fromJson(v));
      });
    }
    seasons = <TvShowSeason>[];
    if (json['seasons'] != null) {
      json['seasons'].forEach((v) {
        seasons.add(TvShowSeason.fromJson(v));
      });
    }
    spokenLanguages = <SpokenLanguages>[];
    if (json['spoken_languages'] != null) {
      json['spoken_languages'].forEach((v) {
        spokenLanguages.add(SpokenLanguages.fromJson(v));
      });
    }
    status = json['status'];
    tagline = json['tagline'];
    type = json['type'];
    voteAverage = json['vote_average'];
    voteCount = json['vote_count'];
  }
}

class CreatedBy {
  int? id;
  String? creditId;
  String? name;
  String? originalName;
  int? gender;
  String? profilePath;

  CreatedBy(
      {this.id,
        this.creditId,
        this.name,
        this.originalName,
        this.gender,
        this.profilePath});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creditId = json['credit_id'];
    name = json['name'];
    originalName = json['original_name'];
    gender = json['gender'];
    profilePath = json['profile_path'];
  }
}

class Genres {
  int? id;
  String? name;

  Genres({this.id, this.name});

  Genres.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class LastEpisodeToAir {
  int? id;
  String? name;
  String? overview;
  double? voteAverage;
  int? voteCount;
  String? airDate;
  int? episodeNumber;
  String? episodeType;
  String? productionCode;
  int? runtime;
  int? seasonNumber;
  int? showId;
  String? stillPath;

  LastEpisodeToAir(
      {this.id,
        this.name,
        this.overview,
        this.voteAverage,
        this.voteCount,
        this.airDate,
        this.episodeNumber,
        this.episodeType,
        this.productionCode,
        this.runtime,
        this.seasonNumber,
        this.showId,
        this.stillPath});

  LastEpisodeToAir.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    overview = json['overview'];
    voteAverage = json['vote_average'];
    voteCount = json['vote_count'];
    airDate = json['air_date'];
    episodeNumber = json['episode_number'];
    episodeType = json['episode_type'];
    productionCode = json['production_code'];
    runtime = json['runtime'];
    seasonNumber = json['season_number'];
    showId = json['show_id'];
    stillPath = json['still_path'];
  }
}

class NextEpisodeToAir {
  int? id;
  String? name;
  String? overview;
  double? voteAverage;
  int? voteCount;
  String? airDate;
  int? episodeNumber;
  String? episodeType;
  String? productionCode;
  int? runtime;
  int? seasonNumber;
  int? showId;
  String? stillPath;

  NextEpisodeToAir(
      {this.id,
        this.name,
        this.overview,
        this.voteAverage,
        this.voteCount,
        this.airDate,
        this.episodeNumber,
        this.episodeType,
        this.productionCode,
        this.runtime,
        this.seasonNumber,
        this.showId,
        this.stillPath});

  NextEpisodeToAir.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    overview = json['overview'];
    voteAverage = json['vote_average'];
    voteCount = json['vote_count'];
    airDate = json['air_date'];
    episodeNumber = json['episode_number'];
    episodeType = json['episode_type'];
    productionCode = json['production_code'];
    runtime = json['runtime'];
    seasonNumber = json['season_number'];
    showId = json['show_id'];
    stillPath = json['still_path'];
  }
}

class Networks {
  int? id;
  String? logoPath;
  String? name;
  String? originCountry;

  Networks({this.id, this.logoPath, this.name, this.originCountry});

  Networks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logoPath = json['logo_path'];
    name = json['name'];
    originCountry = json['origin_country'];
  }
}

class ProductionCompanies {
  int? id;
  String? logoPath;
  String? name;
  String? originCountry;

  ProductionCompanies({this.id, this.logoPath, this.name, this.originCountry});

  ProductionCompanies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logoPath = json['logo_path'];
    name = json['name'];
    originCountry = json['origin_country'];
  }
}

class ProductionCountries {
  String? iso31661;
  String? name;

  ProductionCountries({this.iso31661, this.name});

  ProductionCountries.fromJson(Map<String, dynamic> json) {
    iso31661 = json['iso_3166_1'];
    name = json['name'];
  }
}

class TvShowSeason {
  late String? airDate;
  late int episodeCount;
  late int id;
  late String name;
  late String overview;
  late String? posterPath;
  late int? seasonNumber;
  late double? voteAverage;

  TvShowSeason(
      {this.airDate,
        required this.episodeCount,
        required this.id,
        required this.name,
        required this.overview,
        this.posterPath,
        this.seasonNumber,
        this.voteAverage});

  TvShowSeason.fromJson(Map<String, dynamic> json) {
    airDate = json['air_date'];
    episodeCount = json['episode_count'] ?? 0;
    id = json['id'];
    name = json['name'] ?? "";
    overview = json['overview'] ?? "";
    posterPath = json['poster_path'];
    seasonNumber = json['season_number'];
    voteAverage = json['vote_average'];
  }

  String getPosterUrl() {
    return getTmdbImageUrl(imageUrl: posterPath, width: ImageWidthOptions.w500);
  }
}

class SpokenLanguages {
  String? englishName;
  String? iso6391;
  String? name;

  SpokenLanguages({this.englishName, this.iso6391, this.name});

  SpokenLanguages.fromJson(Map<String, dynamic> json) {
    englishName = json['english_name'];
    iso6391 = json['iso_639_1'];
    name = json['name'];
  }
}
