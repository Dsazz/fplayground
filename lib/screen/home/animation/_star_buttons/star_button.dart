import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fplayground/service/audio_player.dart';
import 'package:get_it/get_it.dart';

typedef StarActionCallback = void Function(Offset currPnt);

class AnimatedStarButton extends StatefulWidget {
  static const KEY_PREFIX = "star_";

  static const double SIZE = 46;
  static const double RADIUS = SIZE * 0.5;
  static const double RADIUS_SHIFT = 3;
  static const double SHADOW_SHIFT = SIZE * 0.25;

  Offset actionPoint;

  StarActionCallback _tryDoAction;

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

    _tryDoAction = state.tryDoAction;

    return state;
  }
}

class AnimatedStarButtonState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  AudioPlayerController player = GetIt.I<AudioPlayerController>();

  AnimationController controller;
  Animation<double> animation;

  AnimationController btnController;
  Animation<double> btnAnimation;

  ValueKey key;

  Offset actionPoint;
  bool actionTaken = false;

  AnimatedStarButtonState(ValueKey key, Offset actionPoint) {
    this.actionPoint = actionPoint;
    this.key = key;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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

    btnController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });
    btnController.repeat(reverse: true);
    btnAnimation = Tween(begin: 1.0, end: 5.0).animate(btnController);
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
    player.play("sound/${key.value}.mp3");

    controller.reset();
    controller.forward();

    actionTaken = true;
  }

  @override
  void dispose() {
    controller.dispose();
    btnController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + animation.value,
      child: SizedBox(
        width: AnimatedStarButton.SIZE,
        height: AnimatedStarButton.SIZE,
        child: GestureDetector(
          onTap: _onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber,
                  blurRadius: btnAnimation.value,
                  spreadRadius: btnAnimation.value,
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const <Widget>[
                const Positioned(
                  top: AnimatedStarButton.SHADOW_SHIFT,
                  left: AnimatedStarButton.SHADOW_SHIFT,
                  child: Icon(Icons.star, color: Colors.black38),
                ),
                const Icon(Icons.star, color: Colors.orange),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    controller.reverse();
  }

  void _onTap() {}
}
