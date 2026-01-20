import 'package:flutter/material.dart';

class CircleBox extends StatelessWidget {
  const CircleBox({
    this.size,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.child,
    this.clipBehavior = Clip.antiAlias,
    this.padding,
    this.shadow,
    super.key,
  });

  final double? size;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? child;
  final Clip clipBehavior;
  final EdgeInsets? padding;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: clipBehavior,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: shadow,
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 1,
              )
            : null,
      ),
      child: child,
    );
  }
}
