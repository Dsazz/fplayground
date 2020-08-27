import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fplayground/screen/home/animation/base_animation.dart';
import 'package:fplayground/service/audio_player.dart';
import 'package:fplayground/util/util.dart';
import 'package:get_it/get_it.dart';
import 'package:path_drawing/path_drawing.dart';

class GhostPainter extends CustomPainter {
  final Animation<double> _animation;
  static const MAX_WIDTH = 266;

  static const HEAD_CIRCLE = 90.0;
  static const WINGS_CIRCLE = 180.0;
  static const BOTTOM_SIDES_CIRCLE = 360.0;
  static const FULL_CIRCLE = 450.0;

  GhostPainter(this._animation) : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (_animation == null) return;

    final value = _animation.value;

    final scaleWidth = MAX_WIDTH / size.width;
    final width = size.width * scaleWidth;
    final height = size.height;

    final middle = height * 0.5;
    final radius = width * 0.155;

    var path = Path();

    final head = Offset(width * 0.51, middle);
    _buildHead(path, head, value, radius);

    _buildWings(path, Offset(width * 0.2, middle), Offset(width * 0.82, middle),
        value, radius);

    final lbSideDy = height * 0.75;
    final rtSideDy = height * 0.95;
    _buildBottomSides(
      path,
      Rect.fromPoints(
        Offset(width * 0.18, lbSideDy),
        Offset(width * 0.42, rtSideDy),
      ),
      Rect.fromPoints(
        Offset(width * 0.61, lbSideDy),
        Offset(width * 0.84, rtSideDy),
      ),
      value,
    );

    _buildBottomMiddle(
      path,
      Rect.fromPoints(
        Offset(width * 0.40, lbSideDy),
        Offset(width * 0.62, rtSideDy),
      ),
      value,
    );

    if (_animation.isCompleted) {
      _drawEyes(canvas, head, middle);
    }

    _drawPath(canvas, path);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _buildHead(Path path, Offset head, double degree, double radius) {
    var degHead = degree >= 0 && HEAD_CIRCLE >= degree ? degree : 0;
    if (degree >= HEAD_CIRCLE) degHead = HEAD_CIRCLE;

    path.addArc(
      Rect.fromCircle(center: head, radius: radius),
      degToRad(270),
      degToRad(-degHead),
    );
    path.addArc(
      Rect.fromCircle(center: head, radius: radius),
      degToRad(270),
      degToRad(degHead),
    );
  }

  void _buildWings(
      Path path, Offset left, Offset right, double degree, double radius) {
    var degWing = degree >= HEAD_CIRCLE && WINGS_CIRCLE >= degree
        ? degree - HEAD_CIRCLE
        : 0;
    if (degree >= WINGS_CIRCLE) degWing = WINGS_CIRCLE - HEAD_CIRCLE;

    path.addArc(
      Rect.fromCircle(center: left, radius: radius),
      degToRad(0),
      degToRad(degWing),
    );
    path.addArc(
      Rect.fromCircle(center: right, radius: radius),
      degToRad(180),
      degToRad(-degWing),
    );
  }

  void _buildBottomSides(
      Path path, Rect leftRect, Rect rightRect, double degree) {
    var degSide = degree >= WINGS_CIRCLE && BOTTOM_SIDES_CIRCLE >= degree
        ? degree - WINGS_CIRCLE
        : 0;
    if (degree >= BOTTOM_SIDES_CIRCLE)
      degSide = BOTTOM_SIDES_CIRCLE - WINGS_CIRCLE;

    path.addArc(leftRect, degToRad(197), degToRad(-degSide));
    path.addArc(rightRect, degToRad(345), degToRad(degSide));
  }

  void _buildBottomMiddle(Path path, Rect rect, double degree) {
    var degMD =
        degree >= BOTTOM_SIDES_CIRCLE ? degree - BOTTOM_SIDES_CIRCLE : 0;

    path.addArc(rect, degToRad(180), degToRad(-degMD));
    path.addArc(rect, degToRad(0), degToRad(degMD));
  }

  void _drawEyes(Canvas canvas, Offset head, double middle) {
    final leftEye = Offset(head.dx - 15, middle);
    final rightEye = Offset(head.dx + 15, middle);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..strokeWidth = 10;

    canvas.drawPoints(PointMode.points, [leftEye, rightEye], paint);
  }

  void _drawPath(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(<double>[10, 9]),
        ),
        paint);
  }
}

class AnimatedGhostPainter extends StatefulWidget implements BaseAnimation {
  VoidCallback _onPressed;

  @override
  void onPressed() {
    return _onPressed();
  }

  @override
  AnimatedGhostPainterState createState() {
    AnimatedGhostPainterState state = AnimatedGhostPainterState();
    _onPressed = state.onPressed;

    return state;
  }
}

class AnimatedGhostPainterState extends State<AnimatedGhostPainter>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  AnimationController _bouncingController;
  Animation<double> _bouncingAnimation;

  AudioPlayerController _player = GetIt.I<AudioPlayerController>();

  void onPressed() {
    _player.play("sound/ghost.mp3");

    if (_bouncingController.isAnimating) _bouncingController.reset();
    _controller.isCompleted ? _controller.reverse() : _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation =
        Tween(begin: 0.0, end: GhostPainter.FULL_CIRCLE).animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    _bouncingController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bouncingAnimation = Tween(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _bouncingController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _player.stopSound();

    _controller?.dispose();
    _bouncingController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animation.isCompleted && _bouncingAnimation.isDismissed) {
      _bouncingController.forward();
      _bouncingController.repeat(reverse: true);
    }

    return Container(
      margin: EdgeInsets.only(bottom: _bouncingAnimation.value),
      child: Container(
        height: 150,
        child: CustomPaint(
          size: Size.infinite,
          foregroundPainter: GhostPainter(_animation),
        ),
      ),
    );
  }
}
