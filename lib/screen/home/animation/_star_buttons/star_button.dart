import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

typedef StarActionCallback = void Function(Offset currPnt);

class AnimatedStarButton extends StatefulWidget {
  static const KEY_PREFIX = "star_";

  Offset actionPoint;

  GestureTapDownCallback _onTapDown;
  GestureTapUpCallback _onTapUp;
  GestureTapCallback _onTap;
  StarActionCallback _tryDoAction;

  void onTapDown(TapDownDetails details) {
    return _onTapDown(details);
  }

  void onTapUp(TapUpDetails details) {
    return _onTapUp(details);
  }

  void onTap() {
    return _onTap();
  }

  void tryDoAction(Offset currPnt) {
    if (_tryDoAction == null) return;
    return _tryDoAction(currPnt);
  }

  AnimatedStarButton(int index, Offset actionPoint)
      : this.actionPoint = actionPoint,
        super(key: ValueKey(KEY_PREFIX + "$index"));

  @override
  AnimatedStarButtonState createState() {
    AnimatedStarButtonState state = AnimatedStarButtonState(key, actionPoint);

    _onTapDown = state.onTapDown;
    _onTapUp = state.onTapUp;
    _onTap = state.onTap;
    _tryDoAction = state.tryDoAction;

    return state;
  }
}

class AnimatedStarButtonState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  AudioCache player = GetIt.I<AudioCache>();

  AnimationController controller;
  Animation<double> animation;

  ValueKey key;

  Offset actionPoint;
  bool actionTaken = false;

  AnimatedStarButtonState(ValueKey key, Offset actionPoint) {
    this.actionPoint = actionPoint;
    this.key = key;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..addListener(() {
        setState(() {});
      });

    animation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: 0.40),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.40, end: 0.0),
          weight: 50.0,
        ),
      ],
    ).animate(CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.02,
          0.04,
          curve: Curves.easeInOutCirc,
        )))
      ..addListener(() {
        setState(() {});
      });
  }

  bool _shouldDoAction(Offset currPnt) {
    if (this.actionTaken) {
      return false;
    }
    return currPnt == actionPoint || currPnt.dx > actionPoint.dx;
  }

  void tryDoAction(Offset currPnt) {
    if (_shouldDoAction(currPnt)) {
      _doAction();
    }
  }

  void _doAction() {
    playSound();

    controller.reset();
    controller.forward();

    actionTaken = true;
  }

  void _stopSound() async {
    await player.fixedPlayer.stop();
  }

  void playSound() async {
    _stopSound();
    player.play("sound/${key.value}.mp3", mode: PlayerMode.LOW_LATENCY);
  }

  @override
  void dispose() {
    _stopSound();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + animation.value,
      child: StarButton(
        onTap: onTap,
        onTapUp: onTapUp,
        onTapDown: onTapDown,
      ),
    );
  }

  void onTapDown(TapDownDetails details) {
    controller.forward();
  }

  void onTapUp(TapUpDetails details) {
    controller.reverse();
  }

  void onTap() {}
}

class StarButton extends StatelessWidget {
  static const double SIZE = 46;
  static const double RADIUS = SIZE * 0.5;
  static const double RADIUS_SHIFT = 3;

  GestureTapDownCallback onTapDown;
  GestureTapUpCallback onTapUp;
  GestureTapCallback onTap;

  StarButton({this.onTapUp, this.onTapDown, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SIZE,
      height: SIZE,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        child: Container(
          width: SIZE,
          height: SIZE,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.amber,
                blurRadius: 6,
                spreadRadius: 3,
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const Positioned(
                top: SIZE * 0.25,
                left: SIZE * 0.25,
                child: Icon(Icons.star, color: Colors.black38),
              ),
              const Icon(Icons.star, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
