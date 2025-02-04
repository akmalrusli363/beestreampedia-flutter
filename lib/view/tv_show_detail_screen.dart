import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/model/response/tv_show_detail_response.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/common_widgets.dart';
import 'package:beestream_pedia/view/tv_show_seasons_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final tvMetadataMetricSection = Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: bigNumberWithCaptions(
                context, item.numberOfSeasons ?? 0, "Seasons")),
        Expanded(
            child: bigNumberWithCaptions(
                context, item.numberOfEpisodes ?? 0, "Episodes")),
        Expanded(
            child: bigCountryFlagWithCaptions(
                context, item.originCountry[0], "Country")),
        if (item.originalLanguage != null && item.originalLanguage!.isNotEmpty)
          Expanded(
              child: bigLanguageFlagWithCaptions(
                  context, item.originalLanguage!, "Original Language")),
      ],
    );
    final tvMetadataInfoContainer = Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        spacing: 8,
        children: [
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
            textAlign: TextAlign.center,
          ),
          starRating(context, (item.voteAverage ?? 0) / 2, 5),
          Text(
            '$rating (${item.voteCount} votes)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (item.genres.isNotEmpty)
            Wrap(
              direction: Axis.horizontal,
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines,
              children: item.genres
                  .map((e) => Chip(
                      label: Text(e.name ?? "",
                          style: Theme.of(context).textTheme.bodySmall)))
                  .toList(),
            ),
            Text(
              'Premiered at: ${item.firstAirDate} - Latest air date: ${item.lastAirDate}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,

          ),
          if (item.createdBy.isNotEmpty)
            inlineField(context,
                textField: Text(
                  'Created by: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                contents: item.createdBy
                    .map((e) =>
                        Chip(label: Text("${e.name} (${e.originalName})")))
                    .toList()),
          if (item.productionCompanies.isNotEmpty)
            inlineField(
              context,
              textField: Text("Production companies: "),
              contents: item.productionCompanies
                  .map((e) =>
                      chipCountry(context, e.name ?? "", e.originCountry ?? ""))
                  .toList(),
              mainAxisAlignment: MainAxisAlignment.center,
            ),
        ],
      ),
    );
    final tvOverviewSection = Container(
        padding: EdgeInsets.all(16),
        child: bigTitleWithContent(
          context,
          title: "Overview",
          child: Text(
            item.overview,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ));
    final tvSeriesSeasonList = Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        Text(
          "Seasons List",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        TvShowSeasonCardList(
            wrapper: TVShowDataWrapper.fromTvShowDetail(item),
            seasons: item.seasons)
      ]),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("${item.name} - (${item.originalName})"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              imageWithPlaceholder(item.getPosterUrl(), height: 360),
              tvMetadataInfoContainer,
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: tvMetadataMetricSection,
              ),
              tvOverviewSection,
              tvSeriesSeasonList,
            ],
          ),
        ),
      ),
    );
  }
}

class TvShowSeasonCardList extends StatelessWidget {
  const TvShowSeasonCardList({
    super.key,
    required this.wrapper,
    required this.seasons,
  });

  final TVShowDataWrapper wrapper;
  final List<TvShowSeason> seasons;

  @override
  Widget build(BuildContext context) {
    seasonCard(index) => TvShowSeasonCard(
        context: context,
        season: seasons[index],
        onSeasonCardClick: () {
          Navigator.push(
            context,
            _gotoSeasonDetailScreen(
                wrapper, (seasons[index].seasonNumber ?? 0)),
          );
        });
    final seasonsListCard = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 450),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: seasons.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return seasonCard(index);
          }),
    );
    return (seasons.isNotEmpty) ? seasonsListCard : Container();
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

class TvShowSeasonCard extends StatelessWidget {
  const TvShowSeasonCard({
    super.key,
    required this.context,
    required this.season,
    required this.onSeasonCardClick,
  });

  final BuildContext context;
  final TvShowSeason season;
  final void Function() onSeasonCardClick;

  @override
  Widget build(BuildContext context) {
    final seasonInfoSection = Column(children: [
      Text(
        season.name,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      if (season.airDate != null && season.airDate!.isNotEmpty)
        (Text(
          "Air date: ${season.airDate}",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        )),
      Text(
        "Season ${season.seasonNumber} - ${season.episodeCount} episodes",
        style: Theme.of(context).textTheme.titleMedium
            ?.apply(fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
      Text(
        season.overview,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    ]);
    final seasonDetailCard = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (season.posterPath != null)
              (Expanded(
                child: imageWithPlaceholder(season.getPosterUrl(), height: 300),
              )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: seasonInfoSection
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
          child: seasonDetailCard,
        ));
  }
}
