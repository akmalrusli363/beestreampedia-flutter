import 'dart:io';

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

String formatDate(DateTime date, {String dateFormat = "d MMMM yyyy"}) {
  return DateFormat(dateFormat, getLocaleString()).format(date);
}