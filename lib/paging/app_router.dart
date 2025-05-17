import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/tv_show_data_wrapper.dart';
import '../view/common_widgets.dart';
import '../view/tv_search_screen.dart';
import '../view/tv_show_catalogue_screen.dart';
import '../view/tv_show_detail_screen.dart';
import '../view/tv_show_seasons_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const TvShowCatalogueScreen(title: 'BeeStreamPedia'),
        routes: [
          _gotoSearchScreen(),
          _gotoShowDetailScreen()
        ]
    ),
  ],
);

GoRoute _gotoShowDetailScreen() {
  return GoRoute(
      name: "detail",
      path: "/detail/:seriesId",
      routes: [
        _gotoSeasonDetailScreen(),
      ],
      pageBuilder: (context, state) {
        final seriesId = state.pathParameters['seriesId'];
        return CustomTransitionPage(
          child: (seriesId == null || seriesId
              .trim()
              .isEmpty)
              ? errorRouter(context, state)
              : TvShowDetailScreen(tvShowId: seriesId),
          transitionsBuilder: (context, animation, secondaryAnimation,
              child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      }
  );
}

GoRoute _gotoSeasonDetailScreen() {
  return GoRoute(
      name: 'seasonDetail',
      path: 'season/:seasonId',
      pageBuilder: (context, state) {
        final seriesId = state.pathParameters['seriesId'];
        final seasonId = state.pathParameters['seasonId'];
        final seriesData = state.extra as TVShowDataWrapper?;
        final page = (seasonId == null || seasonId.trim().isEmpty || seriesId == null)
            ? errorRouter(context, state)
            : TvShowSeasonsDetailScreen(
          seriesId: int.parse(seriesId),
          seasonNo: int.parse(seasonId),
          tvShowData: seriesData,
        );
        return CustomTransitionPage(
          child: page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
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
      });
}

GoRoute _gotoSearchScreen() {
  return GoRoute(
      name: 'search',
      path: "/search",
      pageBuilder: (context, state)
      {
        return CustomTransitionPage(
          child: TvSearchScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
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
      });
}