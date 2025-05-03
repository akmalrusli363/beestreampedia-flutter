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
    final haveImages = seasons.any((e) => e.posterPath?.isNotEmpty == true);
    seasonCard(index) => TvShowSeasonCard(
        context: context,
        season: seasons[index],
        haveImages: haveImages,
        onSeasonCardClick: () {
          Navigator.push(
            context,
            _gotoSeasonDetailScreen(
                wrapper, (seasons[index].seasonNumber ?? 0)),
          );
        });
    final cardHeight = (haveImages) ? TvShowSeasonCard.getCardHeight() : TvShowSeasonCard.descriptionHeight + 8;
    final seasonsListCard = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: cardHeight),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
    this.haveImages = true,
    required this.onSeasonCardClick,
  });

  static const double posterHeight = 320;
  static const double descriptionHeight = 180;

  final BuildContext context;
  final TvShowSeason season;
  final bool haveImages;
  final void Function() onSeasonCardClick;

  static double getCardHeight() {
    return posterHeight + descriptionHeight + 8;
  }

  @override
  Widget build(BuildContext context) {
    final seasonNumbering = season.seasonNumber == 0
        ? "Bonus/Specials"
        : "Season ${season.seasonNumber}";
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
        "$seasonNumbering - ${season.episodeCount} episodes",
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.apply(fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          season.overview,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.justify,
        ),
      ),
    ]);
    final seasonDetailCard = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (haveImages)
              SizedBox(
                  height: posterHeight, // Fixed height for the image
                  child: Builder(builder: (context) {
                    if (season.posterPath != null) {
                      return imageWithPlaceholder(season.getPosterUrl(),
                          height: posterHeight, fillWidth: true);
                    }
                    return SizedBox();
                  })),
            SizedBox(
              height: descriptionHeight,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: seasonInfoSection
                  ),
              ),
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
