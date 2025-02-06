import 'package:flutter/material.dart';

import '../model/response/tv_show_detail_response.dart';
import '../model/tv_show_data_wrapper.dart';
import '../utils/tv_show_utils.dart';
import 'tv_show_seasons_screen.dart';
import 'common_widgets.dart';

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
      if (season.airDate != null)
        (Text(
          "Air date: ${formatDate(season.airDate, dateFormat: "dd MMM yyyy")}",
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
        textAlign: TextAlign.justify,
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