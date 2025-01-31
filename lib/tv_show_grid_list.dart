import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

import 'constants/constants.dart';
import 'model/response/tv_show_list_response.dart';
import 'model/tv_show_data.dart';
import 'package:http/http.dart' as http;

class TvShowGridList extends StatefulWidget {
  const TvShowGridList({Key? key, required this.fetchUrl}) : super(key: key);

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
    _currentPage = 1;
    _futureTvShowList = _fetchTvShowList(_currentPage);
    _scrollController.addListener(_loadMoreItems);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tvShowList.clear();
    super.dispose();
  }

  Future<List<TVShowData>> _fetchTvShowList(int page) async {
    final queryParameters = {
      'page': '$page',
    };
    final response = await http.get(
        Uri.parse(widget.fetchUrl).replace(queryParameters: queryParameters),
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
            return buildList(context, snapshot.requireData);
          } else if (snapshot.hasError) {
            return SingleChildScrollView(
              child: Center(
                child:(Column(
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
              )
            );
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget buildList(BuildContext context, List<TVShowData> items) {
    const fixedCardWidth = 300;
    final deviceWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (deviceWidth / fixedCardWidth).round();

    return MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: max(2, crossAxisCount),
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        padding: const EdgeInsets.all(8.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return tvShowInformationCard(item);
        });
  }

  Widget tvShowInformationCard(TVShowData item) {
    final numberFormat = NumberFormat("0.0#", "en_US");
    final rating = "${numberFormat.format(item.voteAverage)}/10";
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text(
                  '$rating (${item.voteCount} votes)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  item.overview,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ]),
            )
          ],
        ));
  }

  Widget imageWithPlaceholder(String url) {
    return Stack(
      children: <Widget>[
        const SizedBox(
            height: 120, child: Center(child: CircularProgressIndicator())),
        Center(
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: url,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
