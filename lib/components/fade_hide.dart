import 'package:evostream/components/animated_value_builder.dart';
import 'package:evostream/utils/global_utils.dart';
import 'package:flutter/material.dart';

class FadeHide extends StatelessWidget {
  const FadeHide({
    required this.child,
    required this.visible,
    required this.duration,
    this.direction,
    this.fadeScale,
    super.key,
  });

  final Widget child;
  final bool visible;
  final Duration duration;
  final AxisDirection? direction;
  final double? fadeScale;

  @override
  Widget build(BuildContext context) {
    Widget w = AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration,
      child: IgnorePointer(
        ignoring: !visible,
        child: child,
      ),
    );

    if (direction != null || fadeScale != null) {
      w = AnimatedValueBuilder(
        active: !visible,
        duration: duration,
        curve: Curves.easeIn,
        builder: (context, animationValue, child) {
          Offset offset = switch (direction) {
            AxisDirection.up => Offset(0, -animationValue / 2),
            AxisDirection.down => Offset(0, animationValue / 2),
            AxisDirection.left => Offset(-animationValue / 2, 0),
            AxisDirection.right => Offset(animationValue / 2, 0),
            _ => const Offset(0, 0),
          };
          double scale =
              (fadeScale ?? 1) * animationValue + (1 - animationValue);
          return FractionalTranslation(
            translation: offset,
            child: Transform.scale(
              scale: scale,
              child: child!,
            ),
          );
        },
        child: w,
      );
    }

    return w;
  }
}

class Disabled extends StatelessWidget {
  const Disabled({
    required this.child,
    required this.disabled,
    this.opacity = .3,
    super.key,
  });
  final Widget child;
  final bool disabled;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: DefDurations.medium,
      opacity: disabled ? opacity : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: child,
      ),
    );
  }
}

class ScaleFadeOut extends StatelessWidget {
  const ScaleFadeOut({
    required this.child,
    required this.fadeOut,
    required this.duration,
    super.key,
  });

  final Widget child;
  final bool fadeOut;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: fadeOut,
      child: AnimatedOpacity(
        duration: duration,
        opacity: fadeOut ? 0.2 : 1,
        child: AnimatedScale(
          duration: duration,
          scale: fadeOut ? 4 : 1,
          child: child,
        ),
      ),
    );
  }
}
