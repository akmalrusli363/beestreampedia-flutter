import 'dart:math';

import 'package:beestream_pedia/constants/beestream_theme.dart';
import 'package:beestream_pedia/model/response/tv_show_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'common_widgets.dart';

class OverlapImageBackdropSliverAppBar extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  final TvShowDetail item;
  final double scrollOffset;
  final double backdropHeight;
  final double imageHeight;

  OverlapImageBackdropSliverAppBar(this.context,
      {required this.item,
      required this.backdropHeight,
      required this.imageHeight,
      required this.scrollOffset,
      });

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double toolbarOpacity = (2*((shrinkOffset / maxExtent) - 0.5)).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Image.network(
          item.getBackdropUrl(),
          fit: BoxFit.cover,
        ),
        Positioned(
          top: maxExtent - (imageHeight / 2) - scrollOffset,
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: imageWithPlaceholder(item.getPosterUrl(), height: imageHeight),
          ),
        ),
        AppBar(
          title: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: toolbarOpacity,
            child: Text(item.getFullName()),
          ),
          backgroundColor: Color.lerp(Colors.transparent, BeeStreamTheme.appTheme, toolbarOpacity),
          foregroundColor: Colors.white,
        ),
      ],
    );
  }

  @override
  double get maxExtent => backdropHeight + MediaQuery.of(context).padding.top;

  @override
  double get minExtent => kToolbarHeight + MediaQuery.of(context).padding.top;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}