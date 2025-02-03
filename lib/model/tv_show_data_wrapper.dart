import 'package:beestream_pedia/model/response/tv_show_detail_response.dart';
import 'package:beestream_pedia/model/tmdb_config_enums.dart';
import 'package:beestream_pedia/model/tv_show_data.dart';

import '../utils/tv_show_utils.dart';

class TVShowDataWrapper {
  final int id;
  final String name;
  final String originalName;
  final String? posterPath;

  const TVShowDataWrapper({
    required this.id,
    required this.name,
    required this.originalName,
    required this.posterPath,
  });

  String getPosterUrl() {
    return getTmdbImageUrl(imageUrl: posterPath, width: ImageWidthOptions.w500);
  }

  TVShowDataWrapper.fromTvShowData(TVShowData data)
      : id = data.id,
        name = data.name,
        originalName = data.originalName,
        posterPath = data.posterPath;

  TVShowDataWrapper.fromTvShowDetail(TvShowDetail data)
      : id = data.id,
        name = data.name,
        originalName = data.originalName,
        posterPath = data.posterPath;
}
