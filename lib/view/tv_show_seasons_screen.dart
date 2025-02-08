import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/model/response/tv_seasons_detail_response.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/tv_show_episode_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/Constants.dart';
import '../constants/beestream_theme.dart';
import 'common_widgets.dart';

class TvShowSeasonsDetailScreen extends StatefulWidget {
  final TVShowDataWrapper tvShowData;
  final int seasonNo;

  const TvShowSeasonsDetailScreen(
      {super.key, required this.tvShowData, required this.seasonNo});

  @override
  State<TvShowSeasonsDetailScreen> createState() =>
      _TvShowSeasonsDetailScreenState();
}

class _TvShowSeasonsDetailScreenState extends State<TvShowSeasonsDetailScreen> {
  Future<TvSeasonsDetail> _fetchTvSeasonsDetail(
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

  @override
  Widget build(BuildContext context) {
    final Future<TvSeasonsDetail> fItem =
        _fetchTvSeasonsDetail(widget.tvShowData.id, widget.seasonNo);
    return FutureBuilder<TvSeasonsDetail>(
        future: fItem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _detailScreen(
                context, widget.tvShowData, snapshot.requireData);
          } else if (snapshot.hasError) {
            return errorWithStackTrace(context, snapshot);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _detailScreen(
      BuildContext context, TVShowDataWrapper show, TvSeasonsDetail item) {
    final seasonPosterImage = Builder(builder: (context) {
      if (item.posterPath != null && item.posterPath!.isNotEmpty) {
        return imageWithPlaceholder(item.getPosterUrl(), height: 360);
      } else if (show.posterPath != null && show.posterPath!.isNotEmpty) {
        return imageWithPlaceholder(show.getPosterUrl(), height: 360);
      }
      return Container();
    });
    final seasonMetadataInformation = Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "${show.name} - Season ${item.seasonNumber}",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            item.name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (item.voteAverage != null && item.voteAverage! > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                starRating(context, (item.voteAverage ?? 0) / 2, 5),
                Text(
                  "${formatDecimal(item.voteAverage)}/10",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          if (item.airDate != null)
            Text(
              'Premiered at: ${formatDate(item.airDate!)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
    final seasonOverviewSection = Builder(builder: (context) {
      if (item.overview.isNotEmpty) {
        return Container(
            padding: EdgeInsets.all(16),
            child: bigTitleWithContent(
              context,
              title: "Overview",
              child: Text(item.overview,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify),
            ));
      } else {
        return Container();
      }
    });
    final episodeList = Column(
      children: [
        Text(
          "Episodes List",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        TvEpisodeCardList(context: context, episodes: item.episodes)
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("${show.name} - (${item.name})"),
        backgroundColor: BeeStreamTheme.appTheme,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              seasonPosterImage,
              Column(children: [
                seasonMetadataInformation,
                seasonOverviewSection,
                episodeList
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
