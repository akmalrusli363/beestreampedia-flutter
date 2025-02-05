import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:beestream_pedia/constants/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocaleStorage {
  static final LocaleStorage _instance = LocaleStorage._internal();
  factory LocaleStorage() => _instance;
  LocaleStorage._internal();

  static const _languageKey = 'languages';
  static const _countryKey = 'countries';

  final Map<String, String> _languageMap = {};
  final Map<String, String> _countryMap = {};

  Future<void> fetchAndStoreLocales() async {
    final prefs = await SharedPreferences.getInstance();

    final langResponse = await http.get(
      Uri.parse('https://api.themoviedb.org/3/configuration/languages'),
      headers: {
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: tmdbApiKey,
      },
    );
    final countryResponse = await http.get(
      Uri.parse('https://api.themoviedb.org/3/configuration/countries'),
      headers: {
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: tmdbApiKey,
      },
    );

    if (langResponse.statusCode == 200 && countryResponse.statusCode == 200) {
      await prefs.setString(_languageKey, langResponse.body);
      await prefs.setString(_countryKey, countryResponse.body);
      log(langResponse.body);
      log(countryResponse.body);
      _initializeMaps(); // Populate in-memory maps
    } else {
      log("error! unable to correctly fetch language/country key");
    }
  }

  Future<void> _initializeMaps() async {
    final prefs = await SharedPreferences.getInstance();
    final languages = json.decode(prefs.getString(_languageKey) ?? '[]');
    final countries = json.decode(prefs.getString(_countryKey) ?? '[]');

    // Populate language map
    for (var lang in languages) {
      _languageMap[lang['iso_639_1']] = lang['english_name'] ?? lang['name'];
    }

    // Populate country map
    for (var country in countries) {
      _countryMap[country['iso_3166_1']] = country['english_name'];
    }
  }

  String? getLanguageName(String code) => _languageMap[code];
  String? getCountryName(String code) => _countryMap[code];
}