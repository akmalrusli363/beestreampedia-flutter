import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

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
  return Row(
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: [
      textField,
      Flexible(
          fit: FlexFit.loose,
          child: Wrap(
            direction: Axis.horizontal,
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines,
            children: contents,
          ))
    ],
  );
}

Widget chipCountry(BuildContext context, String text, String countryCode) {
  return Chip(
      label: Row(
    mainAxisSize: MainAxisSize.min,
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

Widget imageWithPlaceholder(String url, {double height = 360}) {
  return Stack(
    children: <Widget>[
      SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator())),
      Center(
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          imageErrorBuilder: (context, obj, error) =>
          emptyImagePlaceholder(
            width: height,
            height: height,
            placeholderIcon: Icons.cloud_off,
          ),
          image: url,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    ],
  );
}

Widget emptyImagePlaceholder(
    {required double width,
    required double height,
    required IconData placeholderIcon}) {
  final iconSize = min(width, height) * 0.75;
  return SizedBox(
      width: width.toDouble(),
      height: height.toDouble(),
      child: Icon(
        placeholderIcon,
        size: iconSize,
      ));
}

Widget errorWithStackTrace<T>(BuildContext context, AsyncSnapshot<T> snapshot) {
  return SingleChildScrollView(
      child: Center(
    child: (Column(
      children: [
        Text(
          '${snapshot.error}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'StackTrace: ${snapshot.stackTrace}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    )),
  ));
}

int getCrossAxisGridCountFromScreenSize(BuildContext context,
    {required int fixedWidth, int minCrossAxisCount = 2}) {
  final deviceWidth = MediaQuery.of(context).size.width;
  final crossAxisCount = (deviceWidth / fixedWidth).round();
  return max(minCrossAxisCount, crossAxisCount);
}
