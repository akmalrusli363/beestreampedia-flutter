import 'dart:convert';
import 'dart:io';

import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:beestream_pedia/view/common_widgets.dart';
import 'package:beestream_pedia/view/tv_show_detail_screen.dart';
import 'package:dash_flags/dash_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../model/response/tv_show_list_response.dart';
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
    _initiateFetchUrl();
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
      _initiateFetchUrl();
    }
  }

  void _initiateFetchUrl() {
    _tvShowList.clear();
    _currentPage = 1;
    _futureTvShowList = _fetchTvShowList(_currentPage);
  }

  Future<List<TVShowData>> _fetchTvShowList(int page) async {
    final fetchUri = Uri.parse(widget.fetchUrl);
    final queryParameters = {
      ...fetchUri.queryParameters,
      'page': '$page',
      'language': 'en-ID',
      'region': 'ID',
    };
    final response = await http.get(
      fetchUri.replace(queryParameters: queryParameters),
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
      final fetchedData = TVShowListResponse.fromJson(jsonData).results;
      _tvShowList.addAll(fetchedData);
      return _tvShowList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load TV show list');
    }
  }

  void _loadMoreItems() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentPage += 1;
        debugPrint("continue pagination to $_currentPage...");
        _fetchTvShowList(_currentPage);
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
                    )
                  ],)
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
              Navigator.push(
                context,
                _gotoShowDetailScreen(item.id),
              );
            }
    ));
  }

  Route _gotoShowDetailScreen(int tvShowId) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TvShowDetailScreen(
            tvShowId: tvShowId,
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
