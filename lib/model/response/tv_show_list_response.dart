import '../tv_show_data.dart';

class TVShowListResponse {
  final int page;
  final int totalPages;
  final int totalResults;
  final List<TVShowData> results;

  const TVShowListResponse({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  TVShowListResponse.fromJson(Map<String, dynamic> json)
      :
        page = json['page'] as int,
        totalPages = json['total_pages'] as int,
        totalResults = json['total_results'] as int,
        results = _parseTvShowDataListFromJson(json['results']);

  static List<TVShowData> _parseTvShowDataListFromJson(List<dynamic> json) {
    return json.map((e) => TVShowData.fromJson(e)).toList();
  }

}