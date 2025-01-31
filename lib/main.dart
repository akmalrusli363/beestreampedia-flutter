import 'dart:io';

import 'package:flutter/material.dart';

import 'model/tv_catalog_category.dart';
import 'network/http_certificate_override.dart';
import 'tv_show_grid_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  static const String _discoverTvShowLink = 'https://api.themoviedb.org/3/discover/tv';
  static const String _nowAiringTvShowLink = 'https://api.themoviedb.org/3/tv/airing_today';
  static const String _trendingTvShowLink = 'https://api.themoviedb.org/3/trending/tv/week';
  static const String _popularTvShowLink = 'https://api.themoviedb.org/3/tv/popular';

  int _selectedIndex = 0;
  final _categoryLink = [
    _discoverTvShowLink,
    _trendingTvShowLink,
    _nowAiringTvShowLink,
    _popularTvShowLink,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceIn
      );
    });
  }

  final _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            return TvShowGridList(fetchUrl: _categoryLink[_selectedIndex]);
          },
          itemCount: _categoryLink.length,
        ),
      bottomNavigationBar: buildBottomNavigationBar(context, _onItemTapped, _selectedIndex),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context, void Function(int) onItemTapped, int selectedIndex) {
    return BottomNavigationBar(
      onTap: onItemTapped,
      currentIndex: selectedIndex,
      fixedColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.explore), label: 'Discover'),
        BottomNavigationBarItem(
            icon: Icon(Icons.trending_up), label: 'Trending'),
        BottomNavigationBarItem(
            icon: Icon(Icons.live_tv), label: 'Now Airing'),
        BottomNavigationBarItem(
            icon: Icon(Icons.star), label: 'Popular'),
      ],
    );
  }
}
