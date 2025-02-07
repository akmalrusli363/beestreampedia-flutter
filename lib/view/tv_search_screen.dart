import 'dart:async';

import 'package:beestream_pedia/view/tv_show_grid_list.dart';
import 'package:flutter/material.dart';

import '../constants/beestream_theme.dart';

class TvSearchScreen extends StatefulWidget {
  const TvSearchScreen({super.key});

  @override
  State<TvSearchScreen> createState() => _TvSearchScreenState();
}

class _TvSearchScreenState extends State<TvSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceSearchQuery;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_debounceSearchQuery?.isActive ?? false) {
      _debounceSearchQuery?.cancel();
    }
    _debounceSearchQuery = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: BeeStreamTheme.appTheme,
        foregroundColor: Colors.white,
      ),
      body: Builder(builder: (context) {
        if (_query.isEmpty) {
          return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(Icons.tv, size: 128),
                Text(
                  "Search TV series",
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],)
          );
        } else {
          return _searchResultList();
        }
      }),
    );
  }

  Widget _searchResultList() {
    final fetchUrl = 'https://api.themoviedb.org/3/search/tv?query=$_query';
    return TvShowGridList(fetchUrl: fetchUrl);
  }
}
