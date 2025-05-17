import 'package:beestream_pedia/view/tv_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/beestream_theme.dart';
import '../model/tv_catalog_category.dart';
import 'tv_show_grid_list.dart';

class TvShowCatalogueScreen extends StatefulWidget {
  const TvShowCatalogueScreen({super.key, required this.title});

  final String title;

  @override
  State<TvShowCatalogueScreen> createState() => _TvShowCatalogueScreenState();
}

class _TvShowCatalogueScreenState extends State<TvShowCatalogueScreen> {
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
          duration: const Duration(milliseconds: 200), curve: Curves.bounceIn);
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
        backgroundColor: BeeStreamTheme.appTheme,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {
            context.goNamed('search');
          }, icon: Icon(Icons.search), padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),)
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          return TvShowGridList(fetchUrl: currentTab.fetchUrl);
        },
        itemCount: _tvCatalogCategory.length,
      ),
      bottomNavigationBar:
          buildBottomNavigationBar(context, _onItemTapped, _selectedIndex),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context,
      void Function(int) onItemTapped, int selectedIndex) {
    final navbarItems = _tvCatalogCategory
        .map((e) =>
            {(BottomNavigationBarItem(icon: Icon(e.icon), label: e.title))})
        .expand((set) => set)
        .toList();
    return BottomNavigationBar(
      onTap: onItemTapped,
      currentIndex: selectedIndex,
      fixedColor: BeeStreamTheme.appTheme,
      unselectedItemColor: Colors.grey,
      items: navbarItems,
    );
  }
}
