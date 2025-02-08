import 'dart:math';

import 'package:beestream_pedia/model/response/tv_show_external_id_response.dart';
import 'package:beestream_pedia/model/tmdb_locale_storage.dart';
import 'package:beestream_pedia/model/tv_external_id.dart';
import 'package:beestream_pedia/utils/tv_show_utils.dart';
import 'package:dash_flags/dash_flags.dart';
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
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget bigCountryFlagWithCaptions(
    BuildContext context, String countryCode, String caption) {
  final countryFlagCode =
      ({'as', 'do', 'in', 'is'}.contains(countryCode.toLowerCase()))
          ? 'c_$countryCode'
          : countryCode;
  return Column(children: [
    Tooltip(
        message: LocaleStorage().getCountryName(countryCode) ?? '',
        child: CountryFlag(
          country: Country.fromCode(countryFlagCode),
          height: 32,
        )),
    Text(
      caption,
      style: Theme.of(context).textTheme.titleSmall,
      textAlign: TextAlign.center,
    )
  ]);
}

Widget bigLanguageFlagWithCaptions(
    BuildContext context, String languageCode, String caption) {
  final languageFlagCode =
      ({'as', 'do', 'in', 'is'}.contains(languageCode.toLowerCase()))
          ? 'l_$languageCode'
          : languageCode;
  return Column(children: [
    Tooltip(
        message: LocaleStorage().getLanguageName(languageCode) ?? '',
        child: LanguageFlag(
          language: Language.fromCode(languageFlagCode),
          height: 32,
        )),
    Text(
      caption,
      style: Theme.of(context).textTheme.titleSmall,
      textAlign: TextAlign.center,
    )
  ]);
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
  return Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      textField,
      Wrap(
        direction: Axis.horizontal,
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines,
        children: contents,
      )
    ],
  );
}

Widget bigTitleWithContent(BuildContext context,
    {required String title, required Widget child}) {
  return Column(
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      child
    ],
  );
}

Widget chipCountry(BuildContext context, String text, String countryCode) {
  final countryFlagCode =
      ({'as', 'do', 'in', 'is'}.contains(countryCode.toLowerCase()))
          ? 'c_$countryCode'
          : countryCode;
  return Chip(
      label: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: [
      CountryFlag(
        country: Country.fromCode(countryFlagCode),
        height: 24,
      ),
      Flexible(
          child: Tooltip(
        message: text,
        child: Text(text, overflow: TextOverflow.ellipsis),
      ))
    ],
  ));
}

Widget imageWithPlaceholder(String url, {double? height}) {
  final double minEmptyImageHeight = 120;
  return Stack(alignment: Alignment.center, children: <Widget>[
    Center(child: CircularProgressIndicator()),
    FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      imageErrorBuilder: (context, obj, error) => emptyImagePlaceholder(
        width: height ?? minEmptyImageHeight,
        height: height ?? minEmptyImageHeight,
        placeholderIcon: Icons.cloud_off,
      ),
      image: url,
      height: height,
      fit: BoxFit.cover,
    ),
  ]);
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

Widget? getExternalSiteButton(TvExternalIdResponse? externalId, TvExternalId site) {
  final String? url = externalId?.getExternalUrl(site);
  return (url != null && url.isNotEmpty) ? Tooltip(
    message: '${site.name}: ${externalId?.getExternalAttribute(site) ?? '-'}',
    child: FilledButton(
      style: FilledButton.styleFrom(foregroundColor: site.fgColor, backgroundColor: site.bgColor),
      onPressed: () { gotoSite(url); },
      child: Text(site.name),
    ),
  ) : null;
}
