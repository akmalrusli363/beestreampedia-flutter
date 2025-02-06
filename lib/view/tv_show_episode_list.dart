import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../model/response/tv_show_episode.dart';
import '../utils/tv_show_utils.dart';
import 'common_widgets.dart';

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
            fixedWidth: 360, minCrossAxisCount: 1),
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
    this.showSeason = false,
  });

  final BuildContext context;
  final Episode episode;
  final bool showSeason;

  @override
  Widget build(BuildContext context) {
    final episodeThumbnail = Center(
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          (imageWithPlaceholder(episode.getThumbnailUrl())),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                "#${episode.episodeNumber}",
                style: Theme.of(context).textTheme.headlineLarge?.apply(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black12,
                        offset: Offset(2.0, 2.0),
                      ),
                    ]),
              )),
        ],
      ),
    );
    final episodeInfoSection = Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(children: [
        Text(
          episode.name,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (showSeason)
          Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Season ${episode.seasonNumber} - Episode ${episode.episodeNumber}",
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              )),
        if (episode.overview.isNotEmpty)
          Text(episode.overview,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.justify),
      ]),
    );
    final episodeFooterSection = Container(
      // alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (episode.airDate != null)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Air date: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: formatDate(episode.airDate!),
                    )
                  ],
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.apply(fontStyle: FontStyle.italic),
                textAlign: TextAlign.left,
              ),
            if (episode.voteAverage != null && episode.voteAverage != 0)
              Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    Text('${formatDecimal(episode.voteAverage)}/10')
                  ])
          ],
        ));
    final episodeDetail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            flex: 0,
            child: Builder(builder: (context) {
              if (episode.stillPath != null && episode.stillPath!.isNotEmpty) {
                return episodeThumbnail;
              } else {
                return (emptyImagePlaceholder(
                    width: 120, height: 160, placeholderIcon: Icons.tv));
              }
            })),
        Flexible(flex: 2, child: episodeInfoSection),
        Flexible(flex: 0, child: episodeFooterSection),
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