import 'dart:io';

import 'package:beestream_pedia/model/tmdb_config_enums.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String getLocaleString() {
  try {
    return Platform.localeName;
  } catch (e) {
    return "en-US";
  }
}

String formatDecimal(num? decimal) {
  final numberFormat = NumberFormat("0.0#", getLocaleString());
  return numberFormat.format(decimal ?? 0);
}

String formatDate(DateTime? date, {String dateFormat = "d MMMM yyyy", String defaultEmptyDateText = "n/a"}) {
  if (date != null) {
    return (DateFormat(dateFormat, getLocaleString()).format(date));
  } else {
    return defaultEmptyDateText;
  }
}

String getTmdbImageUrl({required String? imageUrl, ImageWidthOptions width = ImageWidthOptions.w300}) {
  const baseImageUrl = 'https://image.tmdb.org/t/p/';
  return "$baseImageUrl${width.name}/$imageUrl";
}

DateTime? parseDateOrNull(String? dateString) {
  if (dateString != null) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  return null;
}

void gotoSite(String? url) async {
  if (url != null && url.isNotEmpty) {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
