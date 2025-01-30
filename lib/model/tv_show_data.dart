import 'dart:core';

class TVShowData {
  final int id;
  final List<int> genreIds;
  final bool adult;
  final String? backdropPath;
  final List<String>? originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final String firstAirDate;
  final String name;
  final double voteAverage;
  final int voteCount;

  const TVShowData({
    required this.id,
    required this.genreIds,
    required this.adult,
    required this.backdropPath,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.firstAirDate,
    required this.name,
    required this.voteAverage,
    required this.voteCount,
  });

  String getPosterUrl() {
    const baseImageUrl = 'https://image.tmdb.org/t/p/';
    const configSize = 'w780';
    return "$baseImageUrl$configSize/$posterPath";
  }

  String getBackdropUrl() {
    const baseImageUrl = 'https://image.tmdb.org/t/p/';
    const configSize = 'w780';
    return "$baseImageUrl$configSize/$backdropPath";
  }

  TVShowData.fromJson(Map<String, dynamic> json)
      :
        id = json['id'] as int,
        adult = json['adult'] as bool,
        backdropPath = json['backdrop_path'] as String?,
        genreIds = json['genre_ids'].cast<int>(),
        originCountry = json['origin_country']?.cast<String>() ?? [],
        originalLanguage = json['original_language'] as String,
        originalName = json['original_name'] ?? json['original_title'] as String,
        overview = json['overview'] as String,
        popularity = json['popularity'] as double,
        posterPath = json['poster_path'] as String?,
        firstAirDate = json['first_air_date'] ?? json['release_date'] as String,
        name = json['name'] ?? json['title'] as String,
        voteAverage = json['vote_average'] as double,
        voteCount = json['vote_count'] as int;
}
