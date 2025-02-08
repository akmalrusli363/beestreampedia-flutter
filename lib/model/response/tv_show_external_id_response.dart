import 'dart:convert';

import 'package:beestream_pedia/model/tv_external_id.dart';

class TvExternalIdResponse {
  String? imdbId;
  int? tvdbId;
  String? wikidataId;
  String? facebookId;
  String? instagramId;
  String? twitterId;

  TvExternalIdResponse({
    required this.imdbId,
    required this.tvdbId,
    required this.wikidataId,
    required this.facebookId,
    required this.instagramId,
    required this.twitterId,
  });

  factory TvExternalIdResponse.fromRawJson(String str) =>
      TvExternalIdResponse.fromJson(json.decode(str));

  factory TvExternalIdResponse.fromJson(Map<String, dynamic> json) =>
      TvExternalIdResponse(
        imdbId: json["imdb_id"],
        tvdbId: json["tvdb_id"],
        wikidataId: json["wikidata_id"],
        facebookId: json["facebook_id"],
        instagramId: json["instagram_id"],
        twitterId: json["twitter_id"],
      );

  String? getExternalAttribute(TvExternalId site) {
    switch (site) {
      case TvExternalId.imdb:
        return (imdbId != null && imdbId!.isNotEmpty)
            ? imdbId! : null;
      case TvExternalId.tvdb:
        return (tvdbId != null && tvdbId! > 0)
            ? tvdbId!.toString() : null;
      case TvExternalId.wikidata:
        return (wikidataId != null && wikidataId!.isNotEmpty)
            ? wikidataId! : null;
      case TvExternalId.facebook:
        return (facebookId != null && facebookId!.isNotEmpty)
            ? facebookId! : null;
      case TvExternalId.twitter:
        return (instagramId != null && instagramId!.isNotEmpty)
            ? instagramId! : null;
      case TvExternalId.instagram:
        return (twitterId != null && twitterId!.isNotEmpty)
            ? twitterId! : null;
    }
  }

  String? getExternalUrl(TvExternalId site) {
    switch (site) {
      case TvExternalId.imdb:
        return (imdbId != null && imdbId!.isNotEmpty)
            ? (site.baseUrl + imdbId!)
            : null;
      case TvExternalId.tvdb:
        return (tvdbId != null && tvdbId! > 0)
            ? (site.baseUrl + tvdbId!.toString())
            : null;
      case TvExternalId.wikidata:
        return (wikidataId != null && wikidataId!.isNotEmpty)
            ? (site.baseUrl + wikidataId!)
            : null;
      case TvExternalId.facebook:
        return (facebookId != null && facebookId!.isNotEmpty)
            ? (site.baseUrl + facebookId!)
            : null;
      case TvExternalId.twitter:
        return (instagramId != null && instagramId!.isNotEmpty)
            ? (site.baseUrl + instagramId!)
            : null;
      case TvExternalId.instagram:
        return (twitterId != null && twitterId!.isNotEmpty)
            ? (site.baseUrl + twitterId!)
            : null;
    }
  }
}
