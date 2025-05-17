import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/Constants.dart';
import '../model/response/tv_seasons_detail_response.dart';
import '../model/response/tv_show_detail_response.dart';
import '../model/response/tv_show_list_response.dart';
import '../model/tv_show_data.dart';

class TvApiService {
  static const baseUrl = 'https://api.themoviedb.org/3/tv';

  static Future<List<TVShowData>> fetchTvShowList(String fetchUrl, int page) async {
    final fetchUri = Uri.parse(fetchUrl);
    final queryParameters = {
      ...fetchUri.queryParameters,
      'page': '$page',
      'language': 'en-ID',
      'region': 'ID',
    };
    final response = await http.get(
      fetchUri.replace(queryParameters: queryParameters),
      headers: {
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: tmdbApiKey,
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> jsonData =
      jsonDecode(response.body) as Map<String, dynamic>;
      final fetchedData = TVShowListResponse.fromJson(jsonData).results;
      // _tvShowList.addAll(fetchedData);
      return fetchedData;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load TV show list');
    }
  }

  static Future<TvShowDetail> fetchTvShowDetail(String tvShowId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$tvShowId").replace(
          queryParameters: {
            'append_to_response': 'keywords,translations,videos,external_ids'
          }),
      headers: {
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: tmdbApiKey,
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> jsonData =
      jsonDecode(response.body) as Map<String, dynamic>;
      final fetchedData = TvShowDetail.fromJson(jsonData);
      return fetchedData;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load TV show detail');
    }
  }

  static Future<TvSeasonsDetail> fetchTvSeasonsDetail(
      int tvShowId, int season) async {
    final response = await http.get(
      Uri.parse("https://api.themoviedb.org/3/tv/$tvShowId/season/$season"),
      headers: {
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: tmdbApiKey,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData =
      jsonDecode(response.body) as Map<String, dynamic>;
      return TvSeasonsDetail.fromJson(jsonData);
    } else {
      throw Exception('Failed to load TV season detail');
    }
  }
}