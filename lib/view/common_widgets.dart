import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

Widget bigNumberWithCaptions(BuildContext context, num number, String caption) {
  return Column(
    children: [
      Text(
        number.toString(),
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Text(
        caption,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    ],
  );
}

Widget starRating(BuildContext context, double rating, int maxRating) {
  final ratingInteger = min(rating.floor(), maxRating);
  final decimals = rating - ratingInteger;
  final List<Widget> stars = [];
  for (int star = 0; star < ratingInteger; star++) {
    stars.add(const Icon(
      Icons.star,
      color: Colors.orange,
    ));
  }
  if (ratingInteger <= maxRating && decimals >= 0.5 && decimals < 1) {
    stars.add(const Icon(Icons.star_half, color: Colors.orange));
  }
  for (int star = rating.round(); star < maxRating; star++) {
    stars.add(const Icon(Icons.star_outline));
  }

  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    children: stars,
  );
}

Widget inlineField(BuildContext context,
    {required Text textField,
    required List<Widget> contents,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min}) {
  final List<Widget> widgets = [];
  widgets.add(textField);
  widgets.addAll(contents);
  return Row(
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: widgets,
  );
}

Widget chipCountry(BuildContext context, String text, String countryCode) {
  return Chip(
      label: Row(
    children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: CountryFlag.fromCountryCode(
            countryCode,
            height: 24,
            width: 32,
          )),
      Text(text)
    ],
  ));
}
