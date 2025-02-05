import 'dart:io';

import 'package:beestream_pedia/constants/beestream_theme.dart';
import 'package:beestream_pedia/view/tv_show_catalogue_screen.dart';
import 'package:flutter/material.dart';

import 'model/tmdb_locale_storage.dart';
import 'network/http_certificate_override.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleStorage().fetchAndStoreLocales();
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beestream Pedia',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to BeeStreamTheme.appTheme and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: BeeStreamTheme.appTheme,
      ),
      home: const TvShowCatalogueScreen(title: 'Flutter Demo Home Page'),
    );
  }
}
