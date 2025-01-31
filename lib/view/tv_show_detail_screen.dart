import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/model/response/tv_show_detail_response.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/common_widgets.dart';
import 'package:beestream_pedia/view/tv_show_seasons_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import '../constants/constants.dart';

class TvShowDetailScreen extends StatefulWidget {
  final int tvShowId;

  const TvShowDetailScreen({super.key, required this.tvShowId});

  @override
  State<TvShowDetailScreen> createState() => _TvShowDetailScreenState();
}

class _TvShowDetailScreenState extends State<TvShowDetailScreen> {
  Future<TvShowDetail> _fetchTvShowDetail(int tvShowId) async {
    final response = await http.get(
      Uri.parse("https://api.themoviedb.org/3/tv/$tvShowId"),
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

  @override
  Widget build(BuildContext context) {
    final Future<TvShowDetail> fItem = _fetchTvShowDetail(widget.tvShowId);
    return FutureBuilder<TvShowDetail>(
        future: fItem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _detailScreen(context, snapshot.requireData);
          } else if (snapshot.hasError) {
            return errorWithStackTrace(context, snapshot);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _detailScreen(BuildContext context, TvShowDetail item) {
    final rating = "${formatDecimal(item.voteAverage)}/10";
    return Scaffold(
      appBar: AppBar(
        title: Text("${item.name} - (${item.originalName})"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              imageWithPlaceholder(
                item.getPosterUrl(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item.originalName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(fontStyle: FontStyle.italic),
                  ),
                  starRating(context, (item.voteAverage ?? 0) / 2, 5),
                  Text(
                    '$rating (${item.voteCount} votes)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  inlineField(context,
                      textField: Text(
                        'Created by:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      contents: item.createdBy
                          .map((e) => Chip(
                              label: Text("${e.name} (${e.originalName})")))
                          .toList()),
                  Text(
                    'Premiered at: ${item.firstAirDate} - Latest air date: ${item.lastAirDate}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  inlineField(
                    context,
                    textField: Text("Production companies: "),
                    contents: item.productionCompanies
                        .map((e) => chipCountry(
                            context, e.name ?? "", e.originCountry ?? ""))
                        .toList(),
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: bigNumberWithCaptions(
                              context, item.numberOfSeasons ?? 0, "Seasons")),
                      Expanded(
                          child: bigNumberWithCaptions(
                              context, item.numberOfEpisodes ?? 0, "Episodes"))
                    ],
                  ),
                  Text(
                    "Overview",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    item.overview,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "Seasons List",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  tvShowSeasonCardList(
                      TVShowDataWrapper.fromTvShowDetail(item), item.seasons)
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget tvShowSeasonCardList(
      TVShowDataWrapper wrapper, List<TvShowSeason> seasons) {
    return (seasons.isNotEmpty)
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 450),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: seasons.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return tvShowSeasonCard(seasons[index], () {
                    Navigator.push(
                      context,
                      _gotoSeasonDetailScreen(
                          wrapper, (seasons[index].seasonNumber ?? 0)),
                    );
                  });
                }),
          )
        : Container();
  }

  Widget tvShowSeasonCard(
      TvShowSeason season, void Function() onSeasonCardClick) {
    final seasonDetail = ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: 300, maxHeight: 450, minHeight: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (season.posterPath != null)
              (Expanded(
                child: imageWithPlaceholder(season.getPosterUrl(), height: 300),
              )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                Text(
                  season.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (season.airDate != null && season.airDate!.isNotEmpty)
                  (Text(
                    "Air date: ${season.airDate}",
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                Text(
                  "Season ${season.seasonNumber} - ${season.episodeCount} episodes",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.apply(fontStyle: FontStyle.italic),
                ),
                Text(
                  season.overview,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            )
          ],
        ));
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSeasonCardClick,
          child: seasonDetail,
        ));
  }

  Route _gotoSeasonDetailScreen(TVShowDataWrapper wrapper, int seasonNo) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TvShowSeasonsDetailScreen(
        tvShowData: wrapper,
        seasonNo: seasonNo,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
