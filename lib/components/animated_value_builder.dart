import 'package:flutter/material.dart';

class AnimatedValueBuilder extends StatefulWidget {
  const AnimatedValueBuilder({
    required this.active,
    required this.duration,
    required this.builder,
    this.curve,
    this.child,
    super.key,
  });

  final bool active;
  final Duration duration;
  final Widget Function(
    BuildContext context,
    double animationValue,
    Widget? child,
  )
  builder;
  final Curve? curve;
  final Widget? child;

  @override
  State<AnimatedValueBuilder> createState() => _AnimatedValueBuilderState();
}

class _AnimatedValueBuilderState extends State<AnimatedValueBuilder> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.active ? 1 : 0;
  }

  @override
  void didUpdateWidget(covariant AnimatedValueBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      value = widget.active ? 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: value,
      ),
      curve: widget.curve ?? Curves.ease,
      duration: widget.duration,
      child: widget.child,
      builder: (context, value, child) {
        return widget.builder(context, value, child);
      },
    );
  }
}
