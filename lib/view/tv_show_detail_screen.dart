import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/model/response/tv_show_detail_response.dart';
import 'package:beestream_pedia/model/tv_external_id.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/common_widgets.dart';
import 'package:beestream_pedia/view/silver_header_widgets.dart';
import 'package:beestream_pedia/view/tv_show_episode_list.dart';
import 'package:beestream_pedia/view/tv_show_season_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../constants/beestream_theme.dart';
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
      Uri.parse("https://api.themoviedb.org/3/tv/$tvShowId").replace(
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

  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Future<TvShowDetail> fItem = _fetchTvShowDetail(widget.tvShowId);
    getTitle(AsyncSnapshot snapshot) {
      return (snapshot.hasData)
          ? snapshot.requireData.getFullName()
          : "TV Show Information";
    }

    return FutureBuilder<TvShowDetail>(
        future: fItem,
        builder: (context, snapshot) {
          return Scaffold(
              appBar: (!snapshot.hasData)
                  ? AppBar(
                      title: Text(getTitle(snapshot)),
                      backgroundColor: BeeStreamTheme.appTheme,
                      foregroundColor: Colors.white,
                    )
                  : null,
              body: Builder(builder: (context) {
                if (snapshot.hasData) {
                  return _detailScreenWithBackdrop(
                      context, snapshot.requireData);
                } else if (snapshot.hasError) {
                  return errorWithStackTrace(context, snapshot);
                }
                return const Center(child: CircularProgressIndicator());
              }));
        });
  }

  Widget _detailScreenWithBackdrop(BuildContext context, TvShowDetail item) {
    double backdropHeight = 240.0;
    double portraitHeight = 360.0;
    double expandedHeight = (backdropHeight / 2) + portraitHeight
        - MediaQuery.of(context).padding.top;

    double minExtent = kToolbarHeight + MediaQuery.of(context).padding.top;
    double portraitY = (backdropHeight / 2) - (_scrollOffset * 3 / 4) - 16;

    bool collapsed = _scrollOffset > (expandedHeight - minExtent);

    return CustomScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: expandedHeight,
          floating: false,
          pinned: true,
          backgroundColor: BeeStreamTheme.appTheme,
          foregroundColor: Colors.white,
          title: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: collapsed ? 1 : 0,
            child: Text(item.getFullName()),
          ),
          stretch: true,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              return FlexibleSpaceBar(
                stretchModes: [
                  StretchMode.zoomBackground
                ],
                background: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(color: Theme.of(context).scaffoldBackgroundColor),
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: 1 / 2,
                      child: Image.network(
                        item.getBackdropUrl(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: backdropHeight - _scrollOffset,
                      child: Container(
                        height: expandedHeight,
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    Positioned(
                      top: portraitY,
                      child: Card(
        		             elevation: 4,
        		             clipBehavior: Clip.antiAlias,
        		             child: Image.network(item.getPosterUrl(), height: portraitHeight),
        		           ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: _detailScreen(context, item)),
      ],
    );
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
                  .map((e) => Chip(label: Text(e.name ?? "")))
                  .toList(),
            ),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                  text: 'Series status: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: ((item.status ?? '').isNotEmpty)
                      ? item.status
                      : 'unknown'),
            ]),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text.rich(
            TextSpan(text: '', children: [
              TextSpan(
                  text: 'Premiered at: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: formatDate(item.firstAirDate)),
              TextSpan(text: ' - '),
              TextSpan(
                  text: 'Latest air date: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: formatDate(item.lastAirDate)),
            ]),
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
    final tvKeywordsSection = (item.getKeywords().isNotEmpty)
        ? Column(
            children: [
              Text(
                "Keywords:",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                spacing: 4.0,
                children: item
                    .getKeywords()
                    .map((e) => Chip(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        labelPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        label: Text(e.name ?? "",
                            style: Theme.of(context).textTheme.bodySmall)))
                    .toList(),
              ),
            ],
          )
        : Container();
    final gotoSiteButton = Tooltip(
      message: item.homepage,
      child: FilledButton.icon(
          onPressed: () async {
            if (item.homepage != null &&
                !await launchUrl(Uri.parse(item.homepage!))) {
              throw Exception('Could not launch ${item.homepage}');
            }
          },
          icon: Icon(Icons.launch),
          label: Text("OPEN SITE")),
    );
    final externalSiteButtons = [
      getExternalSiteButton(item.externalIds, TvExternalId.imdb) ?? SizedBox(),
      getExternalSiteButton(item.externalIds, TvExternalId.facebook) ?? SizedBox(),
      getExternalSiteButton(item.externalIds, TvExternalId.twitter) ?? SizedBox(),
      getExternalSiteButton(item.externalIds, TvExternalId.instagram) ?? SizedBox(),
    ];
    final tvSeriesActionButtons = Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      spacing: 4.0,
      children: [
        if (item.homepage != null && item.homepage!.isNotEmpty) gotoSiteButton,
        if (item.externalIds != null) ...externalSiteButtons,
      ],
    );
    final tvOverviewSection = Container(
        padding: EdgeInsets.all(16),
        child: bigTitleWithContent(
          context,
          title: "Overview",
          child: (item.overview.isNotEmpty)
              ? Text(
                  item.overview,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                )
              : Text(
                  "No description provided for this TV series",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(fontStyle: FontStyle.italic),
                ),
        ));
    tvSeriesEpisodeOverview(title, episode) {
      if (episode != null) {
        return bigTitleWithContent(context,
            title: title,
            child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 300),
                child: TvEpisodeCard(
                  context: context,
                  episode: episode,
                  showSeason: true,
                )));
      } else {
        return Container();
      }
    }

    final tvEpisodesSection = Wrap(
      alignment: WrapAlignment.center,
      spacing: 32,
      runSpacing: 16,
      children: [
        tvSeriesEpisodeOverview("Latest Episode", item.lastEpisodeToAir),
        tvSeriesEpisodeOverview("Upcoming Episode", item.nextEpisodeToAir),
      ],
    );
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            tvMetadataInfoContainer,
            tvKeywordsSection,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: tvMetadataMetricSection,
            ),
            tvSeriesActionButtons,
            tvOverviewSection,
            tvEpisodesSection,
            tvSeriesSeasonList,
          ],
        ),
      ),
    );
  }
}
