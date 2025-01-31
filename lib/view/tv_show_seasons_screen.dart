import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/model/response/tv_seasons_detail_response.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants/Constants.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("${show.name} - (${item.name})"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (item.posterPath != null && item.posterPath!.isNotEmpty)
                (imageWithPlaceholder(item.getPosterUrl()))
              else if (show.posterPath != null && show.posterPath!.isNotEmpty)
                (imageWithPlaceholder(show.getPosterUrl())),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
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
                  if (item.overview.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          "Overview",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          item.overview,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  Text(
                    "Episodes List",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  tvEpisodeCardList(context, item.episodes)
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget tvEpisodeCardList(BuildContext context, List<Episode> episodes) {
    return (episodes.isNotEmpty)
        ? AlignedGridView.count(
            // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisGridCountFromScreenSize(context,
                fixedWidth: 540, minCrossAxisCount: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: episodes.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return tvEpisodeCard(context, episodes[index]);
            })
        : Container();
  }

  Widget tvEpisodeCard(BuildContext context, Episode episode) {
    final episodeDetail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            flex: 0,
            child: Builder(builder: (context) {
              if (episode.stillPath != null && episode.stillPath!.isNotEmpty) {
                return (imageWithPlaceholder(episode.getThumbnailUrl(),
                    height: 240));
              } else {
                return (emptyImagePlaceholder(
                    width: 500, height: 240, placeholderIcon: Icons.tv));
              }
            })),
        Flexible(
            flex: 2,
            child: Container(
              alignment: Alignment.topCenter,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(children: [
                Text(
                  episode.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  episode.overview,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ]),
            )),
        Flexible(
            flex: 0,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    if (episode.airDate != null)
                      Text(
                        "Air date: ${formatDate(episode.airDate!)}",
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.left,
                      )
                  ],
                )))
      ],
    );
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: episodeDetail,
    );
  }
}
