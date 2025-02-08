import 'package:flutter/material.dart';

enum TvExternalId {
  imdb(
    name: 'IMDB',
    baseUrl: 'https://www.imdb.com/title/',
    bgColor: Colors.amber,
    fgColor: Colors.black,
  ),
  tvdb(
    name: 'TVDB',
    baseUrl: 'https://www.thetvdb.com/dereferrer/series/',
    bgColor: Colors.black38,
    fgColor: Colors.white,
  ),
  wikidata(
    name: 'WikiData',
    baseUrl: 'https://www.wikidata.org/wiki/',
    bgColor: Colors.white70,
    fgColor: Colors.blueGrey,
  ),
  facebook(
    name: 'Facebook',
    baseUrl: 'https://facebook.com/',
    bgColor: Colors.blueAccent,
    fgColor: Colors.white,
  ),
  twitter(
    name: 'X',
    baseUrl: 'https://x.com/',
    bgColor: Colors.black87,
    fgColor: Colors.white,
  ),
  instagram(
    name: 'Instagram',
    baseUrl: 'https://instagram.com/',
    bgColor: Colors.pink,
    fgColor: Colors.white,
  );

  final String name;
  final String baseUrl;
  final Color bgColor;
  final Color fgColor;

  const TvExternalId(
      {required this.name, required this.baseUrl, required this.bgColor, required this.fgColor});
}
