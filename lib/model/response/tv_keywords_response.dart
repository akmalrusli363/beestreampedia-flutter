class TvKeywordsResponse {
  List<TvShowKeywords> results;

  TvKeywordsResponse({
    required this.results
  });

  factory TvKeywordsResponse.fromJson(Map<String, dynamic> json) => TvKeywordsResponse(
    results: (json['results'] != null)
        ? List<TvShowKeywords>.from((json['results'].map((e) => TvShowKeywords.fromJson(e))))
        : []
  );
}

class TvShowKeywords {
  String name;
  int id;

  TvShowKeywords({
    required this.id,
    required this.name,
  });

  factory TvShowKeywords.fromJson(Map<String, dynamic> json) => TvShowKeywords(
    id: json['id'],
    name: json['name'],
  );
}