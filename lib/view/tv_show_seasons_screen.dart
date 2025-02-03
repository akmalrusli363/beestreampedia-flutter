import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/model/response/tv_seasons_detail_response.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

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
                (imageWithPlaceholder(item.getPosterUrl(), height: 360))
              else if (show.posterPath != null && show.posterPath!.isNotEmpty)
                (imageWithPlaceholder(show.getPosterUrl(), height: 360)),
              Column(children: [
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
                  bigTitleWithContent(
                    context,
                    title: "Overview",
                    child: Text(
                      item.overview,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                Text(
                  "Episodes List",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TvEpisodeCardList(context: context, episodes: item.episodes)
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class TvEpisodeCardList extends StatelessWidget {
  const TvEpisodeCardList({
    super.key,
    required this.context,
    required this.episodes,
  });

  final BuildContext context;
  final List<Episode> episodes;

  @override
  Widget build(BuildContext context) {
    return (episodes.isNotEmpty)
        ? AlignedGridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: getCrossAxisGridCountFromScreenSize(context,
                fixedWidth: 450, minCrossAxisCount: 1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: episodes.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return TvEpisodeCard(context: context, episode: episodes[index]);
            })
        : Container();
  }
}

class TvEpisodeCard extends StatelessWidget {
  const TvEpisodeCard({
    super.key,
    required this.context,
    required this.episode,
  });

  final BuildContext context;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final episodeDetail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            flex: 0,
            child: Builder(builder: (context) {
              if (episode.stillPath != null && episode.stillPath!.isNotEmpty) {
                return Center(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      (imageWithPlaceholder(episode.getThumbnailUrl())),
                      Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            "#${episode.episodeNumber}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.apply(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black12,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ]),
                          ))
                    ],
                  ),
                );
              } else {
                return (emptyImagePlaceholder(
                    width: 120, height: 160, placeholderIcon: Icons.tv));
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
                      Text.rich(
                        TextSpan(
                          text: "Air date: ",
                          children: [
                            TextSpan(
                              text: formatDate(episode.airDate!),
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic),
                            )
                          ],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
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
