import 'package:beestream_pedia/network/tv_api_service.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/common_widgets.dart';
import 'package:dash_flags/dash_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../model/tv_show_data.dart';

class TvShowGridList extends StatefulWidget {
  const TvShowGridList({super.key, required this.fetchUrl});

  final String fetchUrl;

  @override
  State<TvShowGridList> createState() => _TvShowGridListState();
}

class _TvShowGridListState extends State<TvShowGridList> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<TVShowData>> _futureTvShowList;
  late int _currentPage;
  final List<TVShowData> _tvShowList = [];

  @override
  void initState() {
    super.initState();
    _futureTvShowList = _initiateFetchUrl();
    _scrollController.addListener(_loadMoreItems);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tvShowList.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TvShowGridList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fetchUrl != widget.fetchUrl) {
      _futureTvShowList = _initiateFetchUrl();
    }
  }

  Future<List<TVShowData>> _initiateFetchUrl() async {
    _tvShowList.clear();
    _currentPage = 1;
    final result = await TvApiService.fetchTvShowList(widget.fetchUrl, _currentPage);
    _tvShowList.addAll(result);
    return _tvShowList;
  }

  Future<List<TVShowData>> _fetchMorePage() async {
    _currentPage += 1;
    final result = await TvApiService.fetchTvShowList(widget.fetchUrl, _currentPage);
    _tvShowList.addAll(result);
    return _tvShowList;
  }

  void _loadMoreItems() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        debugPrint("continue pagination to $_currentPage...");
        _futureTvShowList = _fetchMorePage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TVShowData>>(
        future: _futureTvShowList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final emptyTvShowData = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv_off, size: 128),
                  Text(
                    "No TV series found",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
            return (snapshot.requireData.isNotEmpty)
                ? buildList(context, snapshot.requireData)
                : emptyTvShowData;
          } else if (snapshot.hasError) {
            return SingleChildScrollView(
                child: Center(
              child: (Column(
                children: [
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'StackTrace: ${snapshot.stackTrace}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )),
            ));
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget buildList(BuildContext context, List<TVShowData> items) {
    return MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: getCrossAxisGridCountFromScreenSize(context,
            fixedWidth: 270, minCrossAxisCount: 2),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        padding: const EdgeInsets.all(8.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return TvShowCard(context: context, item: item);
        });
  }
}

class TvShowCard extends StatelessWidget {
  const TvShowCard({
    super.key,
    required this.context,
    required this.item,
  });

  final BuildContext context;
  final TVShowData item;

  @override
  Widget build(BuildContext context) {
    final rating = "${formatDecimal(item.voteAverage)}/10";
    final tvShowInfoSection = Column(children: [
      Text(
        item.name,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      Text(
        item.originalName,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.apply(fontStyle: FontStyle.italic),
      ),
      Text(
        '$rating (${item.voteCount} votes)',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Text(
        item.overview,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.justify,
      ),
      Text.rich(TextSpan(children: [
        WidgetSpan(
            child: CountryFlag(
                country: getCountryFromCode(item.originCountry![0]),
                height: 16)),
        TextSpan(text: ' ${item.getFullOriginCountryName()}')
      ])),
      Text.rich(TextSpan(children: [
        WidgetSpan(child: Icon(Icons.language, size: 16)),
        TextSpan(text: ' ${item.getFullOriginLanguageName()}')
      ])),
    ]);
    final contents = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        imageWithPlaceholder(item.getPosterUrl()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: tvShowInfoSection,
        )
      ],
    );
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            child: contents,
            onTap: () {
              context.goNamed('detail', pathParameters: {'seriesId': "${item.id}"});
            }
    ));
  }
}
