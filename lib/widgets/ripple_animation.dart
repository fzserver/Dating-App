import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:dating/widgets/circle_painter.dart';
import 'dart:async';

class RippleAnimation extends StatefulWidget {

  const RippleAnimation({Key key, this.size = 90.0, this.color = Colors.red, this.onPressed}) : super(key: key);

  final double size;
  final Color color;
  // final Widget child;
  final VoidCallback onPressed;

  @override
  _RippleAnimationState createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation> with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    initAnim();
  }

  Future<void> initAnim() async {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.05)
              ]
            )
          ),
          child: ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: const PulstateCurve(),
              ),
            ),
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Icon(Icons.call, size: 60.0, color: Colors.white,)
              ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          painter: CirclePainter(
            animationController,
            color: widget.color
          ),
          child: SizedBox(
            width: widget.size * 4.125,
            height: widget.size * 4.125,
            child: button(),
          ),
        ),
      ),
    );
  }
}