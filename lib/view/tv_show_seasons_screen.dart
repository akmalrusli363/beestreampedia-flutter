import 'package:beestream_pedia/model/response/tv_seasons_detail_response.dart';
import 'package:beestream_pedia/model/tv_show_data_wrapper.dart';
import 'package:beestream_pedia/network/tv_api_service.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/tv_show_episode_list.dart';
import 'package:flutter/material.dart';

import '../constants/beestream_theme.dart';
import 'common_widgets.dart';

class TvShowSeasonsDetailScreen extends StatefulWidget {
  final TVShowDataWrapper? tvShowData;
  final int seriesId;
  final int seasonNo;

  const TvShowSeasonsDetailScreen(
      {super.key,
      required this.seriesId,
      required this.seasonNo,
      required this.tvShowData});

  @override
  State<TvShowSeasonsDetailScreen> createState() =>
      _TvShowSeasonsDetailScreenState();
}

class TvSeasonDataWrapper {
  final TVShowDataWrapper series;
  final TvSeasonsDetail season;

  TvSeasonDataWrapper({
    required this.series,
    required this.season,
  });
}

class _TvShowSeasonsDetailScreenState extends State<TvShowSeasonsDetailScreen> {
  Future<TvSeasonDataWrapper> _fetchTvSeriesDetail() async {
    final seriesData = widget.tvShowData ??
        TVShowDataWrapper.fromTvShowDetail(
            await TvApiService.fetchTvShowDetail("${widget.seriesId}"));
    final seasonData = await TvApiService.fetchTvSeasonsDetail(
        widget.seriesId, widget.seasonNo);
    return TvSeasonDataWrapper(series: seriesData, season: seasonData);
  }

  @override
  Widget build(BuildContext context) {
    final Future<TvSeasonDataWrapper> fItem = _fetchTvSeriesDetail();
    return FutureBuilder<TvSeasonDataWrapper>(
        future: fItem,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _detailScreen(context, snapshot.requireData.series,
                snapshot.requireData.season);
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
