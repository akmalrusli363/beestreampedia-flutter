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

  int _selectedIndex = 0;
  final _tvCatalogCategory = TvCatalogCategory.values;

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
    final currentTab = _tvCatalogCategory[_selectedIndex];
    return Scaffold(
        appBar: AppBar(
          title: Text(currentTab.title),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            return TvShowGridList(fetchUrl: currentTab.fetchUrl);
          },
          itemCount: _tvCatalogCategory.length,
        ),
      bottomNavigationBar: buildBottomNavigationBar(context, _onItemTapped, _selectedIndex),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context, void Function(int) onItemTapped, int selectedIndex) {
    final navbarItems = _tvCatalogCategory.map((e) => {
      (BottomNavigationBarItem(icon: Icon(e.icon), label: e.title))
    }).expand((set) => set).toList();
    return BottomNavigationBar(
      onTap: onItemTapped,
      currentIndex: selectedIndex,
      fixedColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: navbarItems,
    );
  }
}
