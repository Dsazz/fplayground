import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fplayground/screen/home/animation/_star_buttons/star_button.dart';
import 'package:fplayground/util/util.dart';

class StarLinePath {
  static List<Offset> _calcWrapCirclePoints(
    double center,
    double middleHeight,
    double shift,
  ) {
    return [
      Offset(center - shift, middleHeight - shift),
      Offset(center + shift, middleHeight + shift),
    ];
  }

  static Path build(Size size) {
    final width = size.width;
    final height = size.height;
    final middleHeight = height * 0.5;

    final wrapRadius = AnimatedStarButton.RADIUS * 1.5;

    var path = Path();

    final offsetsWrap1 = _calcWrapCirclePoints(
      (width * 0.2) + AnimatedStarButton.RADIUS_SHIFT,
      middleHeight,
      wrapRadius - AnimatedStarButton.RADIUS_SHIFT,
    );

    final l1WrapOffset = offsetsWrap1[0];
    final r1WrapOffset = offsetsWrap1[1];

    path.moveTo(0, middleHeight);
    path.lineTo(l1WrapOffset.dx, middleHeight);

    final rect = Rect.fromPoints(l1WrapOffset, r1WrapOffset);
    path.addArc(rect, degToRad(180), degToRad(-180));

    final offsetsWrap2 = _calcWrapCirclePoints(
      width * 0.5,
      middleHeight,
      wrapRadius - AnimatedStarButton.RADIUS_SHIFT,
    );
    final l2WrapOffset = offsetsWrap2[0];
    final r2WrapOffset = offsetsWrap2[1];

    path.moveTo(r1WrapOffset.dx, middleHeight);
    path.lineTo(l2WrapOffset.dx, middleHeight);

    path.addArc(
      Rect.fromPoints(l2WrapOffset, r2WrapOffset),
      degToRad(180),
      degToRad(-180),
    );

    final offsetsWrap3 = _calcWrapCirclePoints(
      width * 0.8 - AnimatedStarButton.RADIUS_SHIFT,
      middleHeight,
      wrapRadius - AnimatedStarButton.RADIUS_SHIFT,
    );
    final l3WrapOffset = offsetsWrap3[0];
    final r3WrapOffset = offsetsWrap3[1];

    path.moveTo(r2WrapOffset.dx, middleHeight);
    path.lineTo(l3WrapOffset.dx, middleHeight);

    path.addArc(
      Rect.fromPoints(l3WrapOffset, r3WrapOffset),
      degToRad(180),
      degToRad(-180),
    );

    path.moveTo(r3WrapOffset.dx, middleHeight);
    path.lineTo(width, middleHeight);

    return path;
  }
}
