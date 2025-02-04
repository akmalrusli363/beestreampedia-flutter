import 'dart:io';

import 'package:beestream_pedia/model/tmdb_config_enums.dart';
import 'package:intl/intl.dart';

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
