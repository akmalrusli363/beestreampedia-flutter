import 'package:flutter/material.dart';

enum TvCatalogCategory {
  home(
      "Discover",
      Icons.explore,
      "https://api.themoviedb.org/3/tv/on_the_air"),
  trending(
      "Trending",
      Icons.trending_up,
      "https://api.themoviedb.org/3/trending/tv/week"),
  nowAiring(
      "Airing Today",
      Icons.live_tv,
      "https://api.themoviedb.org/3/tv/airing_today"),
  popular(
      "Popular",
      Icons.star,
      "https://api.themoviedb.org/3/tv/popular"),
  topRated(
      "Top Rated",
      Icons.leaderboard,
      "https://api.themoviedb.org/3/tv/top_rated");

  final String title;
  final IconData icon;
  final String fetchUrl;

  const TvCatalogCategory(this.title, this.icon, this.fetchUrl);
}