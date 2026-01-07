import 'package:flutter/material.dart';

class OpacityTween extends StatelessWidget {
  const OpacityTween({
    super.key,
    this.begin = 0.2,
    this.curve = Curves.easeInToLinear,
    this.duration = const Duration(milliseconds: 700),
    required this.child,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      curve: curve,
      duration: duration,
      builder: (_, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}
